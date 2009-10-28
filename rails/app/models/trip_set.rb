class TripSet
  include Comparable
  include TimeFormatting

  def initialize(options)
    @options = options 
  end

  def result
    now = @options[:now] 
    #@options.merge!(:limit => 10)

    trips = if @options[:trip_id]
      [Trip.find( @options[:trip_id] )] # for the /trip/show action
    else
      @options[:transport_type].to_s.camelize.constantize.trips(@options)
    end

    if trips.empty?
      # send back a message 
      # NOTE that sending any message with cause the app to show an alert
      return {:message => {:title => "Alert", :body => "No more trips for the day"}}
    end
    trip_ids = trips.map(&:id)

    stops = if @options[:trip_id]
              trips.first.stops[(@options[:from_position] - 1)..-1]
            elsif trips.size == 1
              trips[0].stops
            else
              Stop.all(:select => "stops.*, count(*) as num_stoppings", 
                   :joins => :stoppings, 
                   :conditions => ["stoppings.trip_id in (?)", trip_ids], :group => "stoppings.stop_id")
            end
    if stops.empty?
      raise "No stops for params: #{@options.inspect}"
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
      :first_stop => @options[:trip_id] ? [stops.first.name] : trips.map {|t| t.first_stop}.uniq
    }

    result = result.merge( :imminent_stop_ids => imminent_stop_ids(trips) )
    stop_ids = result[:stops].keys
    #ActiveRecord::Base.logger.debug("STOP_IDS (#{stop_ids.size}):\n#{stop_ids.inspect}")

    # Need to add an array of the stop ids in trip order. This is easy for the
    # case of a single trip, but the algorithm for finding a common order for
    # overlapping trips is elusive. Just use a hack for that case for now.
    ordered_stop_ids = if trips.size == 1
      stop_ids
    else
      prelim_ordered_stop_ids = trips[0].stoppings.map {|x| x.stop_id} 
      # cache the signature of this trip
      trip_profiles_seen = [[trips[0].num_stops, trips[0].first_stop, trips[0].last_stop]]
      trips.select {|trip| 
          profile = [trip.num_stops, trip.first_stop, trip.last_stop]
          if trip_profiles_seen.include?(profile)
            false
          else
            trip_profiles_seen << [trip.num_stops, trip.first_stop, trip.last_stop]
            true
          end
      }.each do |trip|
        prelim_ordered_stop_ids = StopOrdering.merge(prelim_ordered_stop_ids, trip.stoppings.map {|x| x.stop_id})
      end
      prelim_ordered_stop_ids
    end
    #ActiveRecord::Base.logger.debug("prelim orderd STOP_IDS: \n#{ordered_stop_ids.inspect}")

    #ActiveRecord::Base.logger.debug("STOP_IDS (#{stop_ids.size}):\n#{stop_ids.inspect}")

    ordered_stop_ids = ordered_stop_ids & stop_ids

    #ActiveRecord::Base.logger.debug("ORDERED STOP_IDS (#{ordered_stop_ids.size}): \n#{ordered_stop_ids.inspect}")

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

  def next_arrivals_for_stop(stop_id, trips, now)
    @all_next_arrivals ||= all_next_arrivals_for_stops(trips, now)
    @all_next_arrivals[stop_id] || []
  end

  def all_next_arrivals_for_stops(trips, now)
    result = ActiveRecord::Base.connection.select_all("select stoppings.stop_id, group_concat(arrival_time) as arrival_times from stoppings " + 
      "where stoppings.trip_id in (#{trips.map(&:id).join(',')}) and stoppings.arrival_time > '#{now.time}' " + 
      "group by stoppings.stop_id")
    data = result.inject({}) do |memo, hash|
      stop_id = hash["stop_id"].to_i
      arrival_times = hash["arrival_times"].split(',').select {|x| x > now.time.to_s}.sort[0,3] # next three
      memo[stop_id] = arrival_times
      memo
    end
    #logger.debug "ALL NEXT ARRIVALS: #{data.inspect}"
    data
  end

  # Returns the stops that trips are about to arrive at
  def imminent_stop_ids(trips)
    now = Time.now.strftime "%H:%M:%S"
    trips.select {|trip| 
      (trip.start_time < now) && (trip.end_time > now)
    }.inject([]) do |memo, trip|
      next_stopping = trip.stoppings.first(:conditions => ["arrival_time > '#{now}'"]) 
      if next_stopping 
        memo << next_stopping.stop_id
      end
      memo
    end.uniq.map {|x| x.to_s} # strings because it's easier to handle this way on iPhone side
  end

end
