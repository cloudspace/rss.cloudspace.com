require 'timeout'

class FeedItemImageProcessingJob < BaseResqueJob
  receives feed_item: FeedItem
  @queue = :image

  def perform
    begin
      Timeout.timeout(300) do
        puts "Processing #{feed_item.title}"
        url = feed_item.image_url
        feed_item.image = url && URI.parse(url)
      end
      feed_item.update_attributes(image_processing: false)
      puts 'Processing complete'
    rescue Timeout::Error, StandardError => e
      feed_item.cleanup_stuck
      feed_item.destroy
    end
  end
end