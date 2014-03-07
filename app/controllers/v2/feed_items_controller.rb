# Controls the feed items.
class V2::FeedItemsController < ApplicationController
  def feed_items
    @feed_items = FeedItem.with_feed_ids(params[:feed_ids]).order(:published_at)
    render json: @feed_items
  end
end
