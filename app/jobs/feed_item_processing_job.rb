require 'timeout'

class FeedItemProcessingJob < BaseResqueJob
  receives feed_item: FeedItem
  @queue = :feed_item

  def perform
    Timeout.timeout(120) do
      feed_item.fetch_and_process
      FeedItemImageProcessingJob.schedule(feed_item)
    end
    feed_item.mark_as_processed!
  end
end
