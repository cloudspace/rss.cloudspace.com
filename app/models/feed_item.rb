# Contains the metadata and content of an individual feed item.
class FeedItem < ActiveRecord::Base
  include Queueable
  include Parseable

  belongs_to :feed

  validates :title, presence: true
  validates :url, presence: true
  validates :feed, presence: true

  scope :processed, -> { where(processed: true) }

  scope :not_processed, -> { where(processed: false) }

  scope :with_feed_ids, ->(feed_ids = []) { processed.where(feed_id: feed_ids) }

  scope :since, lambda { |since = nil|
    processed.where(FeedItem.arel_table[since_field].gteq(since))
  }

  scope :most_recent, -> { processed.order(since_field => :desc).limit(10) }

  # returns all items that are unprocessed and not currenty processing
  scope :ready_for_processing, lambda {
    not_processing.not_processed.order(:created_at)
  }

  # fetches, parses, and updates the feed item and images
  def fetch_and_process
    if parser
      update_attributes(parser.attributes)
    end
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
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/gif', 'image/png']
  do_not_validate_attachment_file_type :image
end
