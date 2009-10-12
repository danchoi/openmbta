class AddAnotherIndexOnServiceExceptions < ActiveRecord::Migration
  def self.up
    add_index :service_exceptions, [:date, :exception_type]
  end

  def self.down
    remove_index :service_exceptions, :column => [:date, :exception_type]
  end
end
