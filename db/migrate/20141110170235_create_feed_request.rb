class CreateFeedRequest < ActiveRecord::Migration
  def change
    create_table :feed_requests do |t|
      t.integer :feed_id
      t.integer :count, default: 0

      t.timestamps
    end
    add_index :feed_requests, :feed_id
  end
end
