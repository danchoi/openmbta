class Trip < ActiveRecord::Base
  include Comparable
  extend TimeFormatting
  belongs_to :route
  belongs_to :service
  has_many :stoppings, :order => "position asc"
  has_many :stops, :through => :stoppings

  # date is a string YYYYMMDD or Date
  def self.for(options) 
    route_id = options[:route_id] ? [options[:route_id]].flatten : nil
    route_type = options[:route_type]
    headsign = options[:headsign]
    # date is a string
    date = options[:date]

    service_ids = Service.active_on(date).map(&:id)

    # Just get the next 10 or so trips that have not finished yet
    now = Time.now.strftime "%H:%M:%S"

    # THIS PART NEEDS TO DIFFER PER TRANSPORT TYPE
    trips = if route_id 
              Trip.all(:conditions => ["route_id in (?) and headsign = ? and service_id in (?) and end_time > '#{now}'", route_id, headsign, service_ids], :order => "start_time asc", :limit => 10)
            else # commuter rail
              Trip.all(:joins => :route,
                       :conditions => ["trips.route_type = ? and routes.mbta_id  = ? and service_id in (?) and end_time > '#{now}'", route_type, headsign, service_ids], :order => "start_time asc", :limit => 10)
            end
    
    if trips.empty?
      # TODO
      raise "TODO get trips from beginning of next day"
      trips = Trip.all(:conditions => ["route_id in (?) and headsign = ? and service_id in (?)", route_id, headsign, service_ids], :order => "start_time desc", :limit => 10)
    end
    if trips.empty?
      raise "No trips for params: #{options.inspect}"
    end
    # END OF PART

    trip_ids = trips.map(&:id)

    stops = Stop.all(:select => "stops.*, count(*) as num_stoppings", :joins => :stoppings, :conditions => ["stoppings.trip_id in (?)", trip_ids], :group => "stoppings.stop_id")
    if stops.empty?
      raise "No stops for params: #{options.inspect}"
    end

    result = { 
      :stops => (stops.inject({}) do |memo, stop|
        memo[stop.id] = {:name => stop.name, 
          :lat => stop.lat, 
          :lng => stop.lng, 
          :num_stoppings => stop.num_stoppings, 
          :next_arrivals => next_arrival_for_stop(stop.id, trips).map {|time| format_time(time)}}
        memo
      end),
      :imminent_stop_ids => imminent_stop_ids(trips),
      :first_stop => trips.map {|t| t.first_stop}.uniq
    }
    # add center coordinates and span, for the iPhone MKMapView
    # TODO make adjustments
    lats  = stops.map {|stop| stop.lat}
    lngs  = stops.map {|stop| stop.lng}
    center_lat = (lats.max + lats.min) / 2 
    center_lng = (lngs.max + lngs.min) / 2
    lat_span = (lats.max - lats.min) * 1.15
    lng_span = (lngs.max - lngs.min) * 1.1
    # Shift center lat up a little to compensate for height of pin
    center_lat = center_lat + (lat_span * 0.05)

    region_info = {
      :region => {:center_lat => center_lat, :center_lng => center_lng, :lat_span => lat_span, :lng_span => lng_span} 
    }

    result.merge!(region_info)
    result
  end

  def self.next_arrival_for_stop(stop_id, trips)
    now = Time.now.strftime "%H:%M:%S"
    ActiveRecord::Base.connection.select_all("select arrival_time from stoppings  " +
      "where stoppings.trip_id in (#{trips.map(&:id).join(',')}) and stoppings.stop_id = #{stop_id} and stoppings.arrival_time > '#{now}' " +
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
