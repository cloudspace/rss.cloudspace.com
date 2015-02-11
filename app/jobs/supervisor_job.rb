require 'timeout'

class SupervisorJob < BaseResqueJob
  @queue = :supervisor

  # def perform
  #   Feed.ready_for_processing.each do |feed|
  #     feed.update_attributes(scheduled: true)
  #     FeedProcessingJob.schedule(feed)
  #   end
  # end
  def perform
    Feed.ready_for_processing.each do |feed|
      feed.update_attributes(scheduled: true)
      feed.lock_element!
      HTTParty.post(ENV['MICROSERVICE_API_URL'] + '/jobs',
                    body: {
                      client_id: ENV['MICROSERVICE_API_KEY'],
                      client_secret: ENV['MICROSERVICE_API_SECRET'],
                      flow_name: ENV['MICROSERVICE_FEED_FLOW_NAME'],
                      callback: "http://#{ENV['MICROSERVICE_APP_HOST']}/v2/feed/#{feed.id}/processed",
                      user_params: {
                        'feedid_1423599518786' => "#{feed.id}",
                        'url_1423599518786' => "#{feed.url}"
                      }
                    }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end
	