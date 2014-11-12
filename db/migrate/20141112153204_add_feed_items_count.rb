class AddFeedItemsCount < ActiveRecord::Migration
  def change
    add_column :feeds, :feed_items_count, :integer, default: 0
  end
end
