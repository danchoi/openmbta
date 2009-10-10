class AddRouteShortNameToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :route_short_name, :string
  end

  def self.down
    remove_column :trips, :route_short_name
  end
end
