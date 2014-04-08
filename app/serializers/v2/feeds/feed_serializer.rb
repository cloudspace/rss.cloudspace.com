# Create the json data for a Feed
class V2::Feeds::FeedSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :icon, :feed_items

  def feed_items
    ActiveModel::ArraySerializer.new(@object.feed_items.processed.most_recent(10),
                                     each_serializer: V2::FeedItems::FeedItemSerializer).as_json
  end

  def icon
    # TODO: make this actually return an icon
    nil
  end
end
