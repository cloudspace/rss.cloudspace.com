class AddFeedErrorsCount < ActiveRecord::Migration
  def change
    add_column :feeds, :feed_errors_count, :integer, default: 0
  end
end
