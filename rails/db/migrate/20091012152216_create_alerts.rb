class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.string :title
      t.string :link
      t.text :description
      t.datetime :pub_date
      t.string :guid
    end
    add_index :alerts, :guid
  end

  def self.down
    drop_table :alerts
  end
end
