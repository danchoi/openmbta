class IndexTripHeadsign < ActiveRecord::Migration
  def self.up
    add_index :trips, :headsign
  end

  def self.down
    remove_index :trips, :column => :headsign
  end
end
