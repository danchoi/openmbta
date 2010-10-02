class AddParentStopCol < ActiveRecord::Migration
  def self.up
    add_column :stops, :parent_stop_id, :string
    add_index :stops, :parent_stop_id
  end

  def self.down
    remove_index :stops, :column => :parent_stop_id
    remove_column :stops, :parent_stop_id
  end
end
