# Creates serialized output (JSON) for a FeedItem.
class V2::FeedItems::FeedItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :url, :author, :image, :summary, :published_at, :created_at, :feed_id

  def image
    nil
  end
end
