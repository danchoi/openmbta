class AddIndexOnServiceId < ActiveRecord::Migration
  def self.up
    add_index :service_exceptions, [:service_id, :exception_type]
  end

  def self.down
    remove_index :service_exceptions, :column => [:service_id, :exception_type]
  end
end
