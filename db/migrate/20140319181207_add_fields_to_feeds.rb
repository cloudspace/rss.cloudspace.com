class AddFieldsToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :processing, :boolean, default: false
    add_index :feeds, :processing
    add_column :feeds, :last_parsed_at, :datetime
    add_index :feeds, :last_parsed_at
    add_column :feeds, :next_parse_at, :datetime
    add_index :feeds, :next_parse_at
    add_column :feeds, :parse_backoff_level, :integer, default: 0
  end
end
