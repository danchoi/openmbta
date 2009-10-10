class CreateServiceExceptions < ActiveRecord::Migration
  def self.up
    create_table :service_exceptions do |t|
      t.integer :service_id
      t.date :date
      t.integer :exception_type
    end
  end

  def self.down
    drop_table :service_exceptions
  end
end
