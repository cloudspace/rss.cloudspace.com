class AddImageProcessingToFeedItem < ActiveRecord::Migration
  def self.up
    add_column :feed_items, :image_processing, :boolean, default: false
  end

  def self.down
    remove_column :feed_items, :image_processing
  end
end
