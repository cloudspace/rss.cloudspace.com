# Creates serialized output (JSON) for a FeedItem.
class V2::FeedItems::FeedItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :url, :author, :summary, :published_at, :created_at, :updated_at,
             :feed_id, :image_iphone_retina, :image_ipad, :image_ipad_retina

  def image_iphone_retina
    url = @object.image.url(:iphone_retina)
    url.present? ? url : FeedItem.default_image(:iphone_retina)
  end

  def image_ipad
    url = @object.image.url(:ipad)
    url.present? ? url : FeedItem.default_image(:ipad)
  end

  def image_ipad_retina
    url = @object.image.url(:ipad_retina)
    url.present? ? url : FeedItem.default_image(:ipad_retina)
  end
end
