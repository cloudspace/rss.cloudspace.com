# Controls the feed items.
class V2::CallbacksController < ApiController
  def feed_item
    feed_item = FeedItem.find(params['feed_item_id'])
    feed_item.update_attributes(title: params['title'],
                                url: params['url'],
                                published_at: params['published_at'],
                                image_file_name: params['image_file_name'],
                                image_content_type: params['image_content_type'],
                                image_file_size: params['image_file_size'],
                                image_url: params['image_url'],
                                image_updated_at: Time.now)
    feed_item.mark_as_processed!
  end
end
