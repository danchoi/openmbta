class IndexStoppingsArrivalTime < ActiveRecord::Migration
  def self.up
    add_index :stoppings, :arrival_time
  end

  def self.down
    remove_index :stoppings, :column => :arrival_time
  end
end
