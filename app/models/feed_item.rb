# Contains the metadata and content of an individual feed item.
class FeedItem < ActiveRecord::Base
  belongs_to :feed

  validates :title, presence: true
  validates :url, presence: true

  scope :with_feed_ids, ->(feed_ids = []) { where(feed_id: feed_ids) }

  scope :since, lambda { |since = nil|
    where(FeedItem.arel_table[since_field].gt(since))
  }

  private

  # Sets up the since field alias.
  #
  # The alias_attribute call below MUST be located AFTER since_field is
  # defined.
  def self.since_field
    :created_at
  end
  alias_attribute :since, since_field
end
