class IndexAlertsOnGuid < ActiveRecord::Migration
  def self.up
    add_index :alerts, :guid
  end

  def self.down
    remove_index :alerts, :column => :guid
  end
end
