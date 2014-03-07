# Contains the metadata and content of an individual feed item.
class FeedItem < ActiveRecord::Base
  belongs_to :feed

  validates :title, presence: true
  validates :url, presence: true

  scope :with_feed_ids, ->(feed_ids = []) { where(feed_id: feed_ids) }

  scope :since, lambda { |since = nil|
    created_at = FeedItem.arel_table[:created_at]
    where(created_at.gt(since))
  }
end
