class CreateRoutes < ActiveRecord::Migration
  def self.up
    create_table :routes do |t|
      t.string :mbta_id 
      t.string :short_name
      t.string :long_name
      t.integer :route_type

      t.timestamps
    end
  end

  def self.down
    drop_table :routes
  end
end
