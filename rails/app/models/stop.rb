class Stop < ActiveRecord::Base
  has_many :stoppings
  has_many :trips, :through => :stoppings
  validates_uniqueness_of :mbta_id

  include TimeFormatting

  # Returns a representation of the upcoming arrivals at this stop
  def arrivals(options)
    logger.debug "ARRIVALS with options: #{options.inspect}"
    stoppings = options[:transport_type].to_s.camelize.constantize.arrivals(self.id, options)
    stoppings.map {|stopping|
      # Discovered the the position field of trips is not reliable. So we must
      # calculate.
      # Would be better if we fixed all the data in the database in one shot.
      trip = stopping.trip
      trip_num_stops = trip.stoppings.count
      position = trip.stoppings.index(stopping) + 1
      more_stops = trip_num_stops - position
      {
        :arrival_time => format_time(stopping.arrival_time),
        :trip_id => stopping.trip_id,
        :more_stops => more_stops == 0 ? "last stop" : "#{more_stops} more #{more_stops == 1 ? 'stop' : 'stops'}", # trip.num_stops - stopping.position,
        :last_stop => trip.last_stop,
        :position => position # stopping.position
      }
    }
  end

  # experimental
  def close_stops 
    sql = "SELECT stops.*, ( 3959 * acos( cos( radians( #{self.lat}  ) ) * cos( radians( stops.lat ) ) * cos( radians( stops.lng ) - radians( #{self.lng} ) ) + sin( radians( #{self.lat} ) ) * sin( radians( stops.lat ) ) ) ) AS distance FROM stops " +
      "where stops.id != #{self.id} " + 
      "HAVING distance < 0.25 ORDER BY distance LIMIT 0 , 20; "

    self.class.find_by_sql sql
  end

  def close_routes
    results = []
    close_stops.each do |stop|
      stop.stoppings.each do |stopping|
        trip = stopping.trip
        data = [stop.name, trip.headsign, trip.route.short_name, trip.route_type]
        unless results.include?(data)
          results << data
        end
      end
    end
    results
  end

  def self.populate
    Generator.generate('stops.txt') do |row|
      Stop.create :mbta_id => row[0],
        :name => row[2],
        :lat => row[4],
        :lng => row[5]
    end
  end

  def self.add_parent_stop_ids
    Generator.generate('stops.txt') do |row|
      next if row[9].blank?
      parent_stop_id = row[9]
      mbta_id = row[0]
      stop = Stop.find_by_mbta_id mbta_id
      puts "#{stop.inspect} -> #{parent_stop_id}"
      stop.update_attributes :parent_stop_mbta_id => parent_stop_id
    end
  end
end
