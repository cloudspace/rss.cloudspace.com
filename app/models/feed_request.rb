class FeedRequest < ActiveRecord::Base
  belongs_to :feed

  validates :feed_id, presence: true

  def count_update
    update_attribute(:count, count + 1)
  end
end
