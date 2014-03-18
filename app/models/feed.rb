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
    feed = Feed.find_by(feed_url: normalize_uri(feed_url))
    unless feed
      parser = Service::Parser::Feed.parse(feed_url)
      if parser.success?
        feed = Feed.create(parser.attributes)
        feed.generate_feed_items
      end
    end
    feed || false
  end

  # fetches and parses the feed, and generates feed items for the feed
  def generate_feed_items
    parser = Service::Parser::Feed.parse(feed_url)
    if parser
      parser.entries_attributes.each do |attrs|
        entry_url = Feed.normalize_uri(attrs[:url])
        FeedItem.find_or_initialize_by(feed_id: id, url: entry_url).update_attributes(attrs)
      end
    else
      false
    end
  end

  private

  def self.normalize_uri(uri)
    URI(uri).normalize.to_s
  end
end
