class CreateServices < ActiveRecord::Migration
  # the calendar table
  def self.up
    create_table :services do |t|
      t.string :mbta_id
      %w{monday tuesday wednesday thursday friday saturday sunday}.each do |day|
        t.boolean day
      end
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end

  def self.down
    drop_table :services
  end
end
