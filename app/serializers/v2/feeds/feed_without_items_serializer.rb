# Create the json data for a Feed without rendering feed items
class V2::Feeds::FeedWithoutItemsSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :icon

  def icon
    # TODO: make this actually return an icon
    nil
  end
end
