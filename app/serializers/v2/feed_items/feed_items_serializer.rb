# Combines feed_items and bad_feed_ids and creates serialized output (JSON).
class V2::FeedItems::FeedItemsSerializer < ActiveModel::Serializer
  self.root = false
  has_many :feed_items, serializer: V2::FeedItems::FeedItemSerializer

  private

  # Don't add bad_feed_ids to the attributes if the array is blank.
  #
  # We don't want to display the bad_feed_ids array in the output if there
  # aren't any.
  def attributes
    hash = super
    hash.merge!(bad_feed_ids: bad_feed_ids) unless bad_feed_ids.blank?
    hash
  end

  def bad_feed_ids
    object[:bad_feed_ids]
  end

  def feed_items
    object[:feed_items]
  end
end
