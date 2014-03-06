class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :url
      t.string :feed_url
      t.text :summary
      t.string :etag
      t.datetime :last_modified_at

      t.timestamps
    end
    add_index :feeds, :last_modified_at
  end
end
