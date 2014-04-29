# Controls the feed items.
class V2::FeedItemsController < ApplicationController
  def index
    feed_ids = validate_feed_ids(Array(params[:feed_ids]))

    return head(:not_found) if feed_ids[:valid].blank?

    feed_items = fetch_feed_items(feed_ids[:valid], params[:since])

    status = feed_ids[:invalid].blank? ? :ok : :partial_content
    render json: { feed_items: feed_items, bad_feed_ids: feed_ids[:invalid] },
           status: status,
           serializer: V2::FeedItems::FeedItemsSerializer
  end

  private

  def validate_feed_ids(feed_ids)
    feed_ids = Array(params[:feed_ids])
    valid_feed_ids = Feed.where(id: feed_ids).pluck(:id).map(&:to_s)
    invalid_feed_ids = feed_ids - good_feed_ids

    {
      valid: valid_feed_ids,
      invalid: invalid_feed_ids
    }
  end

  def fetch_feed_items(feed_ids, since = nil)
    feed_items = FeedItem.processed.with_feed_ids(feed_ids)
    feed_items = feed_items.since(since) unless since.blank?
    feed_items.processed.most_recent.limit_per_feed(10)
  end
end
