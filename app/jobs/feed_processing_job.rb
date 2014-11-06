require 'timeout'

class FeedProcessingJob < BaseResqueJob
  receives feed: Feed
  @queue = :feed

  def perform
    Timeout.timeout(300) do
      process
    end
    feed.mark_as_processed!
  rescue Timeout::Error, StandardError => e
    Rails.logger.error e
    feed.cleanup_stuck
    feed.unlock_element!
  end

  def process
    feed.fetch_and_process
    feed.feed_items.each do |feed_item|
      FeedItemProcessingJob.schedule(feed_item)
    end
  end
end
