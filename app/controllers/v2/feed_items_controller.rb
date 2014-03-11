# Controls the feed items.
class V2::FeedItemsController < ApplicationController
  def feed_items
    feed_ids = Array(params[:feed_ids])
    good_feed_ids = Feed.where(id: feed_ids).pluck(:id).map(&:to_s)
    bad_feed_ids = feed_ids - good_feed_ids

    return head(:not_found) if good_feed_ids.blank?

    feed_items = fetch_feed_items(good_feed_ids, params[:since])

    status = bad_feed_ids.blank? ? :ok : :partial_content
    render json: { feed_items: feed_items, bad_feed_ids: bad_feed_ids },
      status: status,
      serializer: V2::FeedItems::FeedItemsSerializer
  end

  private

  def fetch_feed_items(feed_ids, since = nil)
    feed_items = FeedItem.with_feed_ids(feed_ids)
    feed_items = feed_items.since(since) unless since.blank?
    feed_items
  end
end
