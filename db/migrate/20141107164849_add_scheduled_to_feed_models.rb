class AddScheduledToFeedModels < ActiveRecord::Migration
  def change
    add_column :feed_items, :scheduled, :boolean
    add_column :feeds, :scheduled, :boolean
  end
end
