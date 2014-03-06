# Contains the metadata and content of an individual feed item.
class FeedItem < ActiveRecord::Base
  belongs_to :feed
end
