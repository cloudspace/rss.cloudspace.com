class AddFeedItemSuccess < ActiveRecord::Migration
  def change
    add_column :feed_items, :success, :boolean, default: true
  end
end
