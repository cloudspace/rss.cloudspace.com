# Contains the metadata of a feed.
class Feed < ActiveRecord::Base
  include Queueable
  include Parseable

  has_many :feed_requests
  has_many :feed_items, dependent: :destroy
  has_many :worker_errors, as: :element, dependent: :destroy

  validates :url, presence: true

  # feeds that should be shown on a fresh app install
  scope :default, -> { where(default: true) }

  # feeds that are approved to be searchable
  scope :approved, -> { where(approved: true) }

  # search for a feed by name. returns partial or complete matches
  scope :search_name, ->(str) { approved.where(feeds[:name].matches("%#{str}%")) }

  scope :not_scheduled, -> { where(scheduled: [false, nil]) }

  # returns all feeds that are scheduled and ready for processing,
  # with those most past their scheduled processig time first
  scope :ready_for_processing, lambda {
    not_processing
    .not_scheduled
    .where(feeds[:next_parse_at].lteq(Time.now)
    .or(feeds[:last_parsed_at].eq(nil)))
    .order(:next_parse_at)
  }

  # returns a hash with feed ids as keys and number of feed items processed within date range as values
  # a number of days to go back to is passed on, or it defaults to 30 years ago
  def self.items_processed_in_last_days(number_of = 30 * 365)
    joins(:feed_items).where('feed_items.process_start > ?', Time.now.days_ago(number_of)).group('feeds.id').count
  end

  # generates, saves, and returns a Feed based on a URL, or returns false upon failure
  # returns falsy if feed fails to parse, doesn't exist, or fails to save
  # returns a feed if the feed exists, parses, and saves successfully
  def self.find_or_generate_by_url(url)
    feed = Feed.find_by(url: normalize_uri(url))
    unless feed
      feed = Feed.new(url: url)
      feed.fetch_and_process if feed.parser.success?
    end
    !feed.new_record? && feed
  end

  # fetches, parses, and updates the feed, and generates feed items for the feed
  # also increments/resets backoff interval and sets next parse time
  def fetch_and_process
    if parser && parser.success?
      update_attributes(parser.attributes)
      process_feed_items
    end

    WorkerError.log(self, Exception.new('Less than 10 feed items in feed')) if feed_items.count < 10
  rescue => exception
    WorkerError.log(self, exception)
  ensure
    queue_next_parse
  end

  def process_feed_items(feed_items)
    feed_items.each do |item|
      entry_url = Feed.normalize_uri(item['url'])
      feed_item = FeedItem.find_or_initialize_by(feed_id: id, url: entry_url)
      next unless feed_item.new_record?
      process_feed_item(feed_item, item)
    end
  end

  def process_feed_item(feed_item, item)
    feed_item.update_attributes(title: item['title'],
                                published_at: item['published_at'],
                                scheduled: true)
    feed_item.lock_element!
    feed_item.grab_image
    new_items_found << feed_item
  end

  def new_items_found
    @new_items_found ||= []
  end

  # allows setting image options without affecting existing settings
  # deletes nil/empty keys recursively
  def image_options=(options)
    opts = Service::Options.new(parser_options)
    opts.feed_item!.image_url!.set(options)
    opts.delete_blank!
    update_attributes(parser_options: opts.empty? ? nil : opts)
  end

  # retrieves the image options from the parser_options json
  def image_options
    opts = Service::Options.new(parser_options)
    opts.feed_item || {}
  end

  # removes http from url passed in, and matches url to end of column value
  # will find with http://www.test.com, www.test.com, test.com, http://test.com
  def self.find_with_url(url)
    processed = url.split('//').delete_if { |part| part.downcase == 'http:' || part.downcase == 'https:' }
    Feed.where('url like ?', "%#{processed.join('//')}").first
  end

  # Increments/resets the exponential backoff level, and sets the last and next
  # parse times.
  #
  # @param [Boolean, nil] new_item_found true to reset backoff, false/nil to increment it
  def queue_next_parse
    if new_items_found.present?
      self.parse_backoff_level = Setting.backoff_min
    else
      self.parse_backoff_level = [parse_backoff_level + 1, Setting.backoff_max].min
    end
    interval = [2**(parse_backoff_level + 2), 1440].min
    self.last_parsed_at = Time.now
    self.next_parse_at = Time.now + interval.minutes
    save
  end

  def self.normalize_uri(uri)
    uri && URI(uri).normalize.to_s
  end

  # used for arel
  def self.feeds
    arel_table
  end

  private_class_method :normalize_uri, :feeds
end
