# Contains the metadata of a feed.
class Feed < ActiveRecord::Base
  has_many :feed_items
end
