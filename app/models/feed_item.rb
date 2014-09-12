# Contains the metadata and content of an individual feed item.
class FeedItem < ActiveRecord::Base
  include Queueable
  include Parseable
  # instruct the parseable module to use the specified parser
  @parser_type = :metadata

  belongs_to :feed
  has_many :worker_errors, as: :element, dependent: :destroy

  validates :title, presence: true
  validates :url, presence: true
  validates :feed, presence: true

  scope :processed, -> { where(processed: true) }

  scope :not_processed, -> { where(processed: false) }

  scope :with_feed_ids, ->(feed_ids = []) { where(feed_id: feed_ids) }

  scope :stuck_feed_items, -> { where(processing: true).where('updated_at < ?', Time.now - 5.minutes) }

  scope :since, lambda { |since = nil|
    where(FeedItem.arel_table[since_field].gteq(since))
  }

  # orders results with the most recent first. if a parameter is provided,
  # results are limited to the specified number
  scope :most_recent, ->(max = nil) { order(since_field => :desc).limit(max) }

  # returns all items that are unprocessed and not currenty processing
  scope :ready_for_processing, lambda {
    not_processing.not_processed.order(:created_at)
  }

  # limits the results to (default 10) feed items per distinct feed
  scope :limit_per_feed, lambda { |max = 10|
    where(<<-EOS
      id IN (
        SELECT id FROM (
          SELECT ROW_NUMBER() OVER (
            PARTITION BY feed_id order by #{FeedItem.since_field} DESC)
          AS r, t.* from feed_items t)
        x where x.r <= #{max})
    EOS
    )
  }

  # destroys all but the newest 100 feed items per feed
  def self.cull!(max_per_feed = 15)
    where.not(id: FeedItem.most_recent.limit_per_feed(max_per_feed)).destroy_all
  end

  # If a feed item has been stuck then we forcefully finish it and set the created_at
  # The created_at is set to 1970 so that this item will be culled the next time the feed is processed
  def cleanup_stuck
    self.created_at = Time.new(1970)
    self.processed = true
    self.processing = false
    self.save!
  end

  def self.cleanup_stuck_feed_items
    feed_items = stuck_feed_items
    feed_items.each do |item|
      item.created_at = Time.new(1970)
      item.processed = true
      item.processing = false
      item.save!
    end
  end

  # fetches, parses, and updates the feed item and images
  def fetch_and_process
    Rails.logger.info "\n in fetch_and_process before update_attributes"
    Rails.logger.info "\n in fetch_and_process before update_attributes"
    update_attributes(parser.attributes) if parser
    Rails.logger.info "\n in fetch_and_process after update_attributes"
  end

  # when the image_url attribute is changed, update and process the image
  def image_url=(url)
    self.image = url && URI.parse(url)
    super(url)
  end

  def parser_options
    feed.image_options
  end

  private

  # Sets up the since field alias.
  #
  # The alias_attribute call below this MUST be located AFTER since_field is
  # defined.
  def self.since_field
    :updated_at
  end
  alias_attribute :since, since_field

  # Gets the default image asset URL for the specified type
  #
  # @param type [String, Symbol] The type of image to get (ipad, ipad_retina, iphone_retina)
  def self.default_image(type = :iphone)
    case type.to_sym
    when :ipad_retina
      file_name = 'defaultIpadImage@2x.png'
    when :ipad
      file_name = 'defaultIpadImage.png'
    else
      file_name = 'defaultIphoneImage@2x.png'
    end

    if Rails.application.config.action_controller.asset_host
      URI.join(
        Rails.application.config.action_controller.asset_host,
        'assets/',
        Rails.application.assets.find_asset(file_name).digest_path
      ).to_s
    else
      "/assets/#{file_name}"
    end
  end

  def self.paperclip_path
    ':class/:id/:style.:content_type_extension'
  end

  def self.paperclip_styles
    {
      iphone_retina: '640x800#',
      ipad: '768x960#',
      ipad_retina: '1526x1920#'
    }
  end

  # Sets the paperclip options.
  def self.paperclip_options(storage = nil)
    options = {
      styles: paperclip_styles,
      convert_options: { all: '-quality 40 -strip' },
      default_url: ''
    }
    options.merge paperclip_storage_options(storage)
  end

  # Sets the paperclip storage options based on the storage setting.
  def self.paperclip_storage_options(storage = nil)
    case storage
    when 's3'
      {
        storage: :s3,
        s3_credentials: Rails.root.join('config', 's3.yml'),
        s3_protocol: 'https',
        s3_permissions: :public_read,
        path: paperclip_path
      }
    else
      {
        path: ":rails_root/public/system/#{paperclip_path}",
        url: "#{ENV['HTTPS'] ? 'https' : 'http'}://#{ENV['APP_HOST']}/system/#{paperclip_path}"
      }
    end
  end
  has_attached_file(:image, paperclip_options(ENV['PAPERCLIP_STORAGE']))
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/png', 'image/gif']
  do_not_validate_attachment_file_type :image
end
