class IndexRouteShortName < ActiveRecord::Migration
  def self.up
    add_index :routes, :short_name
    add_index :routes, :route_type
  end

  def self.down
    remove_index :routes, :column => :route_type
    remove_index :routes, :column => :short_name
  end
end
