class CreateWorkerErrors < ActiveRecord::Migration
  def change
    create_table :worker_errors do |t|
      t.string :element_type
      t.integer :element_id
      t.text :element_state
      t.text :message
      t.text :backtrace

      t.timestamps
    end
    add_index :worker_errors, :element_type
    add_index :worker_errors, :element_id
  end
end
