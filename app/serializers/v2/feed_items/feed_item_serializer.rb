# Creates serialized output (JSON) for a FeedItem.
class V2::FeedItems::FeedItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :url, :author, :summary, :published_at, :created_at, :updated_at,
             :feed_id, :iphone_retina_image, :ipad_image, :ipad_retina_image

  def iphone_retina_image
    url = @object.image.url(:iphone_retina)
    url.present? ? url : nil
  end

  def ipad_image
    url = @object.image.url(:ipad)
    url.present? ? url : nil
  end

  def ipad_retina_image
    url = @object.image.url(:ipad_retina)
    url.present? ? url : nil
  end
end
