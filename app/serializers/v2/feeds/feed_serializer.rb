# Create the json data for a Feed
class V2::Feeds::FeedSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :icon
  has_many :feed_items, each_serializer: V2::FeedItems::FeedItemSerializer

  def icon
    # TODO: make this actually return an icon
    nil
  end
end
