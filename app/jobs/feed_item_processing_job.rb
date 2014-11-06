require 'timeout'

class FeedItemProcessingJob < BaseResqueJob
  receives feed_item: FeedItem
  @queue = :feed_item

  def perform
    begin
      Timeout.timeout(300) do
        puts "Processing #{feed_item.title}"
        feed_item.fetch_and_process
        puts "Scheduling image #{feed_item.title}"
        FeedItemImageProcessingJob.schedule(feed_item)
      end
      feed_item.mark_as_processed!
    rescue Timeout::Error, StandardError => e
      feed_item.cleanup_stuck
      feed_item.destroy
    end
  end
end
