class AddIndexToFeedName < ActiveRecord::Migration
  def change
    add_index :feeds, :name
  end
end
