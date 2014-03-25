class RenameColumnsOnFeeds < ActiveRecord::Migration
  def change
    rename_column :feeds, :url, :site_url
    rename_column :feeds, :feed_url, :url
  end
end
