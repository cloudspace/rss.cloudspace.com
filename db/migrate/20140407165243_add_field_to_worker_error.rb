class AddFieldToWorkerError < ActiveRecord::Migration
  def change
    add_column :worker_errors, :exception_class, :string
    add_index :worker_errors, :exception_class
  end
end
