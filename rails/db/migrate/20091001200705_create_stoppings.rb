class CreateStoppings < ActiveRecord::Migration
  def self.up
    create_table :stoppings do |t|
      t.integer :trip_id
      t.integer :stop_id
      t.time :arrival_time
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :stoppings
  end
end
