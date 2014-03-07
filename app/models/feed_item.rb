# Contains the metadata and content of an individual feed item.
class FeedItem < ActiveRecord::Base
  belongs_to :feed

  scope :with_feed_ids, ->(feed_ids = []) { where(feed_id: feed_ids) }

  scope :since, lambda { |since = nil|
    created_at = FeedItem.arel_table[:created_at]
    where(created_at.gt(since))
  }

  def published_at
    if self.published_at > Time.now
      self.created_at
    else
      self.published_at
    end
  end
end
