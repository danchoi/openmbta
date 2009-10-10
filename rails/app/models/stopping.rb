class Stopping < ActiveRecord::Base
  belongs_to :trip
  belongs_to :stop

  def arrival_time
    self.attributes_before_type_cast["arrival_time"]
  end
  def departure_time
    self.attributes_before_type_cast["departure_time"]
  end

  def self.populate
    # because this is a huge file
    index  = 0
    # These are for speeding up this loop by avoiding some SQL queries
    dead_trip_ids = [] 
    dead_stop_ids = []
    Generator.generate('stop_times.txt') do |row|
      index += 1
      if (index % 1000 == 0)
        puts "Row #{index/1000}K" 
        dead_trip_ids = []
        dead_stop_ids = []
      end
      next false if dead_trip_ids.include?(row[0])
      trip = Trip.find_by_mbta_id row[0]
      if trip.nil? 
        dead_trip_ids << row[0]
        next false 
      end
      next false if dead_stop_ids.include?(row[3])
      stop = Stop.find_by_mbta_id row[3]
      if stop.nil? 
        dead_stop_ids << row[0]
        next false
      end

      params = {:trip_id => trip.id,
        :stop_id => stop.id,
        :arrival_time => row[1],
        :departure_time => row[2],
        :position => row[4]}

      # We use this raw sql creation method because Rails can't handle MySQL time type for values >= 24:00:00 (i.e., a.m. stop times)
      Stopping.raw_create params
    end
  end

  def self.raw_create(params)
    stmt = "insert into stoppings (trip_id, stop_id, arrival_time, departure_time, position) values ( #{params[:trip_id]}, #{params[:stop_id]}, '#{params[:arrival_time]}', '#{params[:departure_time]}', #{params[:position]}) "
    self.connection.execute(stmt)
  end

end
