class AddFeeditemDied < ActiveRecord::Migration
  def self.up
    add_column :feed_items, :process_killed, :datetime
    add_column :feeds, :process_killed, :datetime
  end

  def self.down
    remove_column :feed_items, :process_killed, :datetime
    remove_column :feeds, :process_killed, :datetime
  end
end
