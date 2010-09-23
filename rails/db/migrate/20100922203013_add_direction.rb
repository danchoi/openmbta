class AddDirection < ActiveRecord::Migration
  def self.up
    add_column :trips, :direction_id, :integer 
  end

  def self.down
    remove_column :trips, :direction_id
  end
end
