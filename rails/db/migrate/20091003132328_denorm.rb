class Denorm < ActiveRecord::Migration
  def self.up
    add_column :trips, :service_start_date, :date
    add_column :trips, :service_end_date, :date
    %w{monday tuesday wednesday thursday friday saturday sunday}.each do |day|
      add_column :trips, day, :boolean 
    end
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
      remove_column :trips, day
    raise ActiveRecord::IrreversableMigration
    remove_column :trips, :service_end_date
    remove_column :trips, :service_start_date
  end
end
