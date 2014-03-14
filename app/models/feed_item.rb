# Contains the metadata and content of an individual feed item.
class FeedItem < ActiveRecord::Base
  belongs_to :feed

  validates :title, presence: true
  validates :url, presence: true
  validates :feed, presence: true

  scope :with_feed_ids, ->(feed_ids = []) { where(feed_id: feed_ids) }

  scope :since, lambda { |since = nil|
    where(FeedItem.arel_table[since_field].gteq(since))
  }

  scope :most_recent, -> { order(since_field => :desc).limit(10) }

  private

  # Sets up the since field alias.
  #
  # The alias_attribute call below this MUST be located AFTER since_field is
  # defined.
  def self.since_field
    :created_at
  end
  alias_attribute :since, since_field

  # Sets the paperclip options.
  def self.paperclip_options(storage = nil)
    options = {
      styles: {
        :'640x800' => '640x800#', # iphone
        :'768x960' => '768x960#', # ipad_mini
        :'1526x1920' => '1526x1920#' # ipad
      },
      convert_options: { all: '-quality 40 -strip' }
    }
    options.merge paperclip_storage_options(storage)
  end

  # Sets the paperclip storage options based on the storage setting.
  def self.paperclip_storage_options(storage = nil)
    case storage
    when :s3
      {
        storage: :s3,
        s3_credentials: Rails.root.join('config', 's3.yml'),
        s3_permissions: :public,
        path: ':class/:id/:style.:content_type_extension'
      }
    else
      {
        path: ':rails_root/public/system/:class/:id/:style.:content_type_extension'
      }
    end
  end
  has_attached_file(:image, paperclip_options(ENV['PAPERCLIP_STORAGE']))
  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/gif', 'image/png']
  do_not_validate_attachment_file_type :image
end
