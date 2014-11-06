require 'timeout'

class FeedItemImageProcessingJob < BaseResqueJob
  receives feed_item: FeedItem
  @queue = :image

  def perform
    Timeout.timeout(300) do
      url = feed_item.image_url
      feed_item.image = url && URI.parse(url)
    end
    feed_item.update_attributes(image_processing: false)
  rescue Timeout::Error, StandardError => e
    Rails.logger.error e
    feed_item.cleanup_stuck
    feed_item.destroy
  end
end
