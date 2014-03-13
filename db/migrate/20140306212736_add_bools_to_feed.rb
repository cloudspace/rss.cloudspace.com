class AddBoolsToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :default, :boolean, default: false
    add_index :feeds, :default
    add_column :feeds, :approved, :boolean, default: true
    add_index :feeds, :approved
  end
end
