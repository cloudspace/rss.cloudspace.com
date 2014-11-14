class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :name
      t.integer :value

      t.timestamps
    end
    add_index :settings, :name, unique: true
  end
end
