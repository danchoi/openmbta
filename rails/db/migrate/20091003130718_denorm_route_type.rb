class DenormRouteType < ActiveRecord::Migration
  def self.up
    add_column :trips, :route_type, :integer
  end

  def self.down
    remove_column :trips, :route_type
  end
end
