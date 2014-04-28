# Creates serialized output (JSON) for a FeedItem.
class V2::FeedItems::FeedItemSerializer < ActiveModel::Serializer
  attributes :id, :title, :url, :author, :summary, :published_at, :created_at, :updated_at,
             :feed_id, :image_iphone_retina, :image_ipad, :image_ipad_retina

  def image_iphone_retina
    url = @object.image.url(:iphone_retina)

    if url.present?
      url
    else
      URI::join(Rails.application.config.action_controller.asset_host, "/assets/", Rails.application.assets.find_asset("defaultIphoneImage@2x.png").digest_path).to_s
    end
  end

  def image_ipad
    url = @object.image.url(:ipad)

    if url.present?
      url
    else
      URI::join(Rails.application.config.action_controller.asset_host, "/assets/", Rails.application.assets.find_asset("defaultIpadImage.png").digest_path).to_s
    end
  end

  def image_ipad_retina
    url = @object.image.url(:ipad_retina)

    if url.present?
      url
    else
      URI::join(Rails.application.config.action_controller.asset_host, "/assets/", Rails.application.assets.find_asset("defaultIpadImage@2x.png").digest_path).to_s
    end
  end
end
