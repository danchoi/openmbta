class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.string :mbta_id
      t.integer :route_id  # use internal rails ids
      t.integer :service_id
      t.string :headsign
      t.timestamps
    end
  end

  def self.down
    drop_table :trips
  end
end
