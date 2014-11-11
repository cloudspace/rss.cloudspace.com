require 'timeout'

class SupervisorJob < BaseResqueJob
  @queue = :supervisor

  def perform
    Feed.ready_for_processing.each do |feed|
      feed.update_attributes(scheduled: true)
      FeedProcessingJob.schedule(feed)
    end
  end
end
