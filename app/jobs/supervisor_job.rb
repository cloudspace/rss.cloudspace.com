require 'timeout'

class SupervisorJob < BaseResqueJob
  @queue = :supervisor

  def perform
    Feed.ready_for_processing.each do |feed|
      feed.update_attributes(scheduled: true)
      feed.lock_element!
      HTTParty.post(ENV['MICROSERVICE_API_URL'] + '/jobs',
                    body: {
                      client_id: ENV['MICROSERVICE_API_KEY'],
                      client_secret: ENV['MICROSERVICE_API_SECRET'],
                      flow_name: 'gofeedrunner',
                      callback: "http://#{ENV['MICROSERVICE_APP_HOST']}/v2/feeds/#{feed.id}/processed",
                      user_params: {
                        'feedid_1424720512793' => "#{feed.id}",
                        'url_1424720512793' => "#{feed.url}"
                      }
                    }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end
