class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :stoppings, :stop_id
    add_index :trips, :route_id
    add_index :trips, :service_id
    add_index :stoppings, :trip_id
  end

  def self.down
    remove_index :stoppings, :column => :trip_id
    remove_index :trips, :column => :service_id
    remove_index :trips, :column => :route_id
    remove_index :stoppings, :column => :stop_id
  end
end
