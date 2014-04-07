class AddParserOptionsToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :parser_options, :json
  end
end
