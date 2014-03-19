class AddProcessedToFeedItem < ActiveRecord::Migration
  def change
    add_column :feed_items, :processed, :boolean, default: false
    add_index :feed_items, :processed
  end
end
