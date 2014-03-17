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

  # generates, saves, and returns a Feed based on a URL, or returns false upon failure
  def self.find_or_generate_by_url(feed_url)
    normalized_uri = URI(feed_url).normalize.to_s
    feed = Feed.find_by(feed_url: normalized_uri)
    if feed
      feed
    else
      parser = Service::Parser::Feed.parse(normalized_uri)
      parser.success? ? Feed.create(parser.attributes) : false
    end
  end
end
