class IndexMbtaId < ActiveRecord::Migration
  def self.up
    add_index :trips, :mbta_id
    add_index :stops, :mbta_id
  end

  def self.down
    remove_index :stops, :column => :mbta_id
    remove_index :trips, :column => :mbta_id
  end
end
