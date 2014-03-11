# Combines the feed_items and bad_feed_ids hashes for serialized output (JSON).
class V2::FeedItems::FeedItemsSerializer < ActiveModel::Serializer
  self.root = false

  def serializable_hash
    serialized_feed_items.merge serialized_bad_feed_ids
  end

  private

  def bad_feed_ids
    object[:bad_feed_ids]
  end

  def feed_items
    object[:feed_items]
  end

  def serialized_feed_items
    {
      feed_items: ActiveModel::ArraySerializer.new(
        feed_items,
        each_serializer: V2::FeedItems::FeedItemSerializer
      )
    }
  end

  def serialized_bad_feed_ids
    return { bad_feed_ids: bad_feed_ids } unless bad_feed_ids.blank?
    {}
  end
end
