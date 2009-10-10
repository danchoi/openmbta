class AddDepartureTimeToStoppings < ActiveRecord::Migration
  def self.up
    add_column :stoppings, :departure_time, :time
  end

  def self.down
    remove_column :stoppings, :departure_time
  end
end
