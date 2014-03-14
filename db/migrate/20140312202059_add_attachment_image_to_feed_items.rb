class AddAttachmentImageToFeedItems < ActiveRecord::Migration
  def self.up
    change_table :feed_items do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :feed_items, :image
  end
end
