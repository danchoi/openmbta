class IndexTripsEndTime < ActiveRecord::Migration
  def self.up
    add_index :trips, :end_time
  end

  def self.down
    remove_index :trips, :column => :end_time
  end
end
