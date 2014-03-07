# Controls the feed items.
class V2::FeedItemsController < ApplicationController
  def feed_items
    feed_ids = Array(params[:feed_ids])
    good_feed_ids = Feed.where(id: feed_ids).pluck(:id).map(&:to_s)
    bad_feed_ids = feed_ids - good_feed_ids

    return head(:not_found) if good_feed_ids.blank?

    feed_items = fetch_feed_items(good_feed_ids, params[:since])

    status = bad_feed_ids.blank? ? :ok : :partial_content
    render json: generate_feed_items_content(feed_items, bad_feed_ids), status: status
  end

  private

  def fetch_feed_items(feed_ids, since = nil)
    feed_items = FeedItem.with_feed_ids(feed_ids)
    feed_items = feed_items.since(since) unless since.blank?
    feed_items
  end

  def serialized_feed_items(feed_items)
    {
      feed_items: ActiveModel::ArraySerializer.new(feed_items, {
        each_serializer: V2::FeedItems::FeedItemSerializer
      })
    }
  end

  def serialized_bad_feed_ids(bad_feed_ids)
    return { bad_feed_ids: bad_feed_ids } unless bad_feed_ids.blank?
    {}
  end

  def generate_feed_items_content(feed_items, bad_feed_ids = nil)
    content = serialized_feed_items(feed_items)
    content.merge!(serialized_bad_feed_ids(bad_feed_ids))
    content
  end
end
