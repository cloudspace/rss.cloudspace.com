# Contains the metadata of a feed.
class Feed < ActiveRecord::Base
  has_many :feed_items

  validates :feed_url, presence: true

  # feeds that should be shown on a fresh app install
  scope :default, -> { where(default: true) }

  # feeds that are approved to be searchable
  scope :approved, -> { where(approved: true) }

  # search for a feed by name. returns partial or complete matches
  scope :search_name, ->(str) { approved.where(arel_table[:name].matches("%#{str}%")) }

  # generates an url
  def self.generate_from_url
    # TODO: make this make feed and verify it that it exists and is parseable
    true
  end
end
