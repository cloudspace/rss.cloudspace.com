require 'timeout'
require 'httparty'

class FeedProcessingJob < BaseResqueJob
  receives feed: Feed
  @queue = :feed

  def perform
    Timeout.timeout(120) do
      process
    end
    feed.mark_as_processed!
  end

  def process
    feed.lock_element!
    feed.fetch_and_process
    feed.feed_items.ready_for_processing.each do |feed_item|
      feed_item.update_attributes(scheduled: true)
      feed_item.lock_element!
      url = ENV['MICROSERVICE_API_DEV'] + '/api/flows/17/run?api_key=' + ENV['MICROSERVICE_API_KEY'] + ''\
            '&url_48=' + feed_item.url.to_s + '&s3_image_prefix_47=feed_items/' + feed_item.id.to_s + ''\
            '&new_image_name_47=iphone_retina&resize_string_47=640x800'\
            '&s3_image_prefix_45=feed_items/' + feed_item.id.to_s + '&new_image_name_45=ipad'\
            '&resize_string_45=768x960&s3_image_prefix_46=feed_items/' + feed_item.id.to_s + ''\
            '&new_image_name_46=ipad_retina&resize_string_46=1526x1920'\
            '&s3_prefix_44=feed_items/' + feed_item.id.to_s + '&new_file_name_44=original'\
            '&feed_item_id_49=' + feed_item.id.to_s + '&feed_id_49=' + feed.id.to_s + ''\
            '&url_49=' + feed_item.url.to_s + ''\
            '&published_at_49=' + URI.encode(feed_item.published_at.to_s) + ''\
            '&title_49=' + URI.encode(feed_item.title) + ''\
            '&callback=http://33.33.164.176:3000/v2/feed_items/' + feed_item.id.to_s + '/callback'
      HTTParty.get(url)
    end
  end
end
