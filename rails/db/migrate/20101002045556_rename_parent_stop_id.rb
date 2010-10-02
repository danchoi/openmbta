class RenameParentStopId < ActiveRecord::Migration
  def self.up
    rename_column :stops, :parent_stop_id, :parent_stop_mbta_id
  end

  def self.down
    rename_column :stops, :parent_stop_mbta_id, :parent_stop_id
  end
end
