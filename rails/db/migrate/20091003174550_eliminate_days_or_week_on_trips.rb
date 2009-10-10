class EliminateDaysOrWeekOnTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :schedule_type, :string
    %w{monday tuesday wednesday thursday friday saturday sunday}.each do |day|
      remove_column :trips, day
    end
  end

  def self.down
    remove_column :trips, :schedule_type
  end
end
