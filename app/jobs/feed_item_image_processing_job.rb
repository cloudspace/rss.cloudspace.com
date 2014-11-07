require 'timeout'

class FeedItemImageProcessingJob < BaseResqueJob
  receives feed_item: FeedItem
  @queue = :image
  @retry_limit = 1

  def perform
    Timeout.timeout(300) do
      url = feed_item.image_url
      feed_item.image = url && URI.parse(url)
    end
    feed_item.update_attributes(image_processing: false)
  end
end
