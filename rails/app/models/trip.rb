class Trip < ActiveRecord::Base
  include Comparable
  extend TimeFormatting
  belongs_to :route
  belongs_to :service
  has_many :stoppings, :order => "position asc"
  has_many :stops, :through => :stoppings


  def self.for(options) 
    now = options[:now] 
    #options.merge!(:limit => 10)

    trips = if options[:trip_id]
      [Trip.find( options[:trip_id] )] # for the /trip/show action
    else
      options[:transport_type].to_s.camelize.constantize.trips(options)
    end

    if trips.empty?
      # send back a message 
      # NOTE that sending any message with cause the app to show an alert
      return {:message => {:title => "Alert", :body => "No more trips for the day"}}
    end
    trip_ids = trips.map(&:id)

    stops = if options[:trip_id]
              trips.first.stops[(options[:from_position] - 1)..-1]
            elsif trips.size == 1
              trips[0].stops
            else
              Stop.all(:select => "stops.*, count(*) as num_stoppings", 
                   :joins => :stoppings, 
                   :conditions => ["stoppings.trip_id in (?)", trip_ids], :group => "stoppings.stop_id")
            end
    if stops.empty?
      raise "No stops for params: #{options.inspect}"
    end

    result = { 
      :stops => (stops.inject({}) do |memo, stop|
        memo[stop.id] = {:name => stop.name, 
          :lat => stop.lat, 
          :lng => stop.lng, 
          :num_stoppings => stop.respond_to?(:num_stoppings) ? stop.num_stoppings : 1, 
          :next_arrivals => next_arrivals_for_stop(stop.id, trips, now).map {|time| format_time(time)}}
        memo
      end),
      :imminent_stop_ids => imminent_stop_ids(trips),
      :first_stop => options[:trip_id] ? [stops.first.name] : trips.map {|t| t.first_stop}.uniq
    }

    # Need to add an array of the stop ids in trip order. This is easy for the
    # case of a single trip, but the algorithm for finding a common order for
    # overlapping trips is elusive. Just use a hack for that case for now.
    ordered_stop_ids = if trips.size == 1
      stops.map {|stop| stop.id}
    else
      # a hack for now
      initial_ordered_stop_ids = trips[0].stoppings.map {|x| x.stop_id} 
      # just stick in the rest  into a union
      initial_ordered_stop_ids | result[:stops].keys
    end

    result = result.merge(:ordered_stop_ids => ordered_stop_ids)

    # Add center coordinates and span, for the iPhone MKMapView
    # TODO make adjustments
    lats  = stops.map {|stop| stop.lat}
    lngs  = stops.map {|stop| stop.lng}
    center_lat = lats.size > 1 ? ((lats.max + lats.min) / 2) : lats[0]
    center_lng = lngs.size > 1 ? ((lngs.max + lngs.min) / 2) : lngs[0]

    lat_span = lats.size > 1 ? ((lats.max - lats.min) * 0.95) : 0.0219
    lng_span = lngs.size > 1 ? ((lngs.max - lngs.min) * 0.9) : 0.023
    # Shift center lat up a little to compensate for height of pin
    center_lat = center_lat + (lat_span * 0.05)

    region_info = {
      :region => {:center_lat => center_lat, :center_lng => center_lng, :lat_span => lat_span, :lng_span => lng_span} 
    }

    result.merge(region_info)
  end

  def self.next_arrivals_for_stop(stop_id, trips, now)
    ActiveRecord::Base.connection.select_all("select arrival_time from stoppings  " +
      "where stoppings.trip_id in (#{trips.map(&:id).join(',')}) and stoppings.stop_id = #{stop_id} and stoppings.arrival_time > '#{now.time}' " +
      "order by stoppings.arrival_time limit 3" ).map {|x| x["arrival_time"]}
  end

  # Returns the stops that trips are about to arrive at
  def self.imminent_stop_ids(trips)
    now = Time.now.strftime "%H:%M:%S"
    trips.inject([]) do |memo, trip|
      next_stopping = trip.stoppings.detect {|stopping| 
        # can compare mysql time type as strings and it works
        stopping.arrival_time.to_s > now
      }
      if next_stopping 
        memo << next_stopping.stop_id
      else
        memo
      end
    end.uniq.map {|x| x.to_s} # strings because it's easier to handle this way on iPhone side
  end

  def stops_with_times
    stoppings.map {|stopping| 
      [stopping.stop.name, stopping.time]
    }
  end

  def print_stops
    stops_with_times.each {|x|
      puts "%s %s" % [x[1], x[0]]
    }
  end

  def start_time
    self.attributes_before_type_cast["start_time"]
  end

  def end_time
    self.attributes_before_type_cast["end_time"]
  end

  def <=>(other) 
    self.start_time <=> other.start_time
  end 


  def self.populate
    Generator.generate('trips.txt') do |row|
      route = Route.find_by_mbta_id row[0]
      service = Service.find_by_mbta_id row[1]
      Trip.create :route => route,
        :service => service,
        :mbta_id => row[2],
        :headsign => row[3]
    end
  end

  named_scope :missing_stops_summary, :conditions => "start_time is null or end_time is null"

  def self.denormalize
    self.all.each {|trip| trip.denormalize}
  end

  def denormalize
    self.denorm_service_days
    return if self.stoppings.empty?

    first_stopping = self.stoppings.first(:order => 'position asc')
    last_stopping = self.stoppings.first(:order => 'position desc')
    num_stops = self.stoppings.count

    self.update_attributes :first_stop => first_stopping.stop.name,
      :last_stop => last_stopping.stop.name,
      :num_stops => num_stops,
      :route_type => self.route.route_type

    self.raw_update(first_stopping, last_stopping)
    print '.'
  end

  named_scope :with_null_start_time, :conditions => "start_time is null"

  # We use this raw sql creation method because Rails can't handle MySQL time type for values >= 24:00:00 (i.e., a.m. stop times)
  def raw_update(first_stopping, last_stopping)
    stmt = "update trips set start_time = '#{first_stopping.arrival_time}', end_time = '#{last_stopping.arrival_time}' where id = #{self.id}"
    puts "Executing #{stmt}"
    self.connection.execute(stmt)
  end

  def denorm_service_days
    sched_type = if service.monday
                   "weekday"
                 elsif service.saturday
                   "saturday"
                 elsif service.sunday
                   "sunday"
                 end
    if service.start_date == service.end_date
      sched_type = "holiday"
    end
    params = { :service_start_date => service.start_date,
      :service_end_date => service.end_date, 
      :schedule_type => sched_type
    }
    update_attributes params
  end

end
