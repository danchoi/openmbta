class DenormTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :start_time, :time
    add_column :trips, :end_time, :time
    add_column :trips, :first_stop, :string
    add_column :trips, :last_stop, :string
    add_column :trips, :num_stops, :integer

  end

  def self.down
    remove_column :trips, :num_stops
    remove_column :trips, :last_stop
    remove_column :trips, :first_stop
    remove_column :trips, :end_time
    remove_column :trips, :start_time
  end
end
