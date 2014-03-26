class ChangeColumnTypesToText < ActiveRecord::Migration
  def change
    change_column :feeds, :url, :text
    change_column :feeds, :name, :text
    change_column :feeds, :site_url, :text
    change_column :feed_items, :title, :text
    change_column :feed_items, :url, :text
    change_column :feed_items, :author, :text
  end
end
