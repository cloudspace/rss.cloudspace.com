# Create the json data for a FeedItem.
class V2::FeedItems::FeedItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :url, :author, :image, :summary, :published_at, :created_at
  has_one :feed, serializer: V2::Feeds::FeedSerializer

  def image
    nil
  end
end
