# Creates serialized output (JSON) for a FeedItem.
class V2::FeedItems::FeedItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :url, :author, :images, :summary, :published_at, :created_at, :updated_at, :feed_id

  private

  def images
    images = {}
    object.image.styles.keys.each do |style|
      url = object.image.url(style)
      images[style] = url.blank? ? nil : url
    end
    images
  end
end
