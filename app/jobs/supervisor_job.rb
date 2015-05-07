require 'timeout'

class SupervisorJob < BaseResqueJob
  @queue = :supervisor

  def perform
    Feed.ready_for_processing.each do |feed|
      feed.update_attributes(scheduled: true)
      feed.lock_element!
      callback = "http://#{ENV['MICROSERVICE_APP_HOST']}/v2/feeds/#{feed.id}/processed"
      runner = Microservice::Runner.new('go-feed-processor', 'beattiem', callback)
      runner.run('feedid' => "#{feed.id}", 'url' => "#{feed.url}")
    end
  end
end
