require 'timeout'

class FeedProcessingJob < BaseResqueJob
  receives feed: Feed
  @queue = :feed

  def perform
    begin
      Timeout.timeout(300) do
        puts "Processing #{feed.url}"
        feed.fetch_and_process
        feed.feed_items.each do |feed_item|
          puts "Scheduling feed item #{feed_item.title}"
          FeedItemProcessingJob.schedule(feed_item)
        end
      end
      feed.mark_as_processed!
    rescue Timeout::Error, StandardError => e
      feed.cleanup_stuck
      # record_error(e)
      feed.unlock_element!
    end
  end
end
