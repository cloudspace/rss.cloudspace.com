class AddProcessingToFeedItem < ActiveRecord::Migration
  def change
    add_column :feed_items, :processing, :boolean, default: false
    add_index :feed_items, :processing
  end
end
