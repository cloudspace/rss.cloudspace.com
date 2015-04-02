# Controls the feed items.
class V2::FeedItemsController < ApiController
  def index
    return head(:not_found) if feed_ids[:valid].blank?

    feed_items = fetch_feed_items(feed_ids[:valid], params[:since])

    feed_ids[:valid].map { |feed_id| FeedRequest.find_or_create_by(feed_id: feed_id).count_update }

    status = feed_ids[:invalid].blank? ? :ok : :partial_content

    render json: { feed_items: feed_items, bad_feed_ids: feed_ids[:invalid] },
           status: status,
           serializer: V2::FeedItems::FeedItemsSerializer
  end

  def callback
    puts params
  end

  def image_processed
    feed_item = FeedItem.find(params[:id])
    feed_item.process_image(params['url'])
  end

  def complete
    feed_item = FeedItem.find(params[:id])
    feed_item.complete(params['imagedata'])
    feed_item.mark_as_processed!
  end

  private

  def feed_ids
    @feed_ids ||= validate_feed_ids(Array(params[:feed_ids]))
  end

  def validate_feed_ids(feed_ids)
    feed_ids = Array(params[:feed_ids])
    valid_feed_ids = Feed.where(id: feed_ids).pluck(:id).map(&:to_s)
    invalid_feed_ids = feed_ids - valid_feed_ids

    {
      valid: valid_feed_ids,
      invalid: invalid_feed_ids
    }
  end

  def fetch_feed_items(feed_ids, since = nil)
    feed_items = FeedItem.processed.image_done.with_feed_ids(feed_ids)
    feed_items = feed_items.since(since) unless since.blank?
    feed_items.processed.image_done.most_recent.limit_per_feed(10)
  end
end
