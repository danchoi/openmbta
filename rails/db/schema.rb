# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091007205534) do

  create_table "routes", :force => true do |t|
    t.string  "mbta_id"
    t.string  "short_name"
    t.string  "long_name"
    t.integer "route_type"
  end

  create_table "service_exceptions", :force => true do |t|
    t.integer "service_id"
    t.date    "date"
    t.integer "exception_type"
  end

  create_table "services", :force => true do |t|
    t.string  "mbta_id"
    t.boolean "monday"
    t.boolean "tuesday"
    t.boolean "wednesday"
    t.boolean "thursday"
    t.boolean "friday"
    t.boolean "saturday"
    t.boolean "sunday"
    t.date    "start_date"
    t.date    "end_date"
  end

  create_table "stoppings", :force => true do |t|
    t.integer "trip_id"
    t.integer "stop_id"
    t.time    "arrival_time"
    t.integer "position"
    t.time    "departure_time"
  end

  add_index "stoppings", ["stop_id"], :name => "index_stoppings_on_stop_id"
  add_index "stoppings", ["trip_id"], :name => "index_stoppings_on_trip_id"

  create_table "stops", :force => true do |t|
    t.string "mbta_id"
    t.string "name"
    t.float  "lat"
    t.float  "lng"
  end

  add_index "stops", ["mbta_id"], :name => "index_stops_on_mbta_id"

  create_table "trips", :force => true do |t|
    t.string  "mbta_id"
    t.integer "route_id"
    t.integer "service_id"
    t.string  "headsign"
    t.time    "start_time"
    t.time    "end_time"
    t.string  "first_stop"
    t.string  "last_stop"
    t.integer "num_stops"
    t.integer "route_type"
    t.date    "service_start_date"
    t.date    "service_end_date"
    t.string  "route_short_name"
    t.string  "schedule_type"
  end

  add_index "trips", ["headsign"], :name => "index_trips_on_headsign"
  add_index "trips", ["mbta_id"], :name => "index_trips_on_mbta_id"
  add_index "trips", ["route_id"], :name => "index_trips_on_route_id"
  add_index "trips", ["service_id"], :name => "index_trips_on_service_id"

end
