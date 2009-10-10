class CreateStops < ActiveRecord::Migration
  def self.up
    create_table :stops do |t|
      t.string :mbta_id
      t.string :name
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end

  def self.down
    drop_table :stops
  end
end
