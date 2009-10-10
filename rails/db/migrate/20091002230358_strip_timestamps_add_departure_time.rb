class StripTimestampsAddDepartureTime < ActiveRecord::Migration
  def self.up
    [:trips, :stops, :stoppings, :routes, :services].each do |x|
      remove_column x, :created_at
      remove_column x, :updated_at
    end
  end

  def self.down
  end
end
