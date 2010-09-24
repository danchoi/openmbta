class Grid
  include TimeFormatting


  def initialize(route_short_name, headsign, first_stop=nil)
    now = Now.new
    date = now.date
    service_ids = Service.active_on(date).map(&:id)
    conditions = if first_stop
                   ["routes.short_name = ? and headsign = ? and first_stop = ? and service_id in (?)", route_short_name, headsign, first_stop, service_ids]
                 else 
                   ["routes.short_name = ? and headsign = ? and service_id in (?)", route_short_name, headsign, service_ids]
                 end
    @trips = Trip.all(:joins => :route, 
                      :conditions => conditions,
                      :order => "start_time asc")
  end

  def grid
    trips = @trips
    trip_ids = @trips.map(&:id)
    stops = if @trips.size == 1
              @trips[0].stops
            else
              Stop.all(:select => "stops.*, count(*) as num_stoppings", 
                   :joins => :stoppings, 
                   :conditions => ["stoppings.trip_id in (?)", trip_ids], 
                   :group => "stoppings.stop_id")
                   
            end

    @grid = [] 
    @first_stops = []
    @trips.each_with_index do |trip, col|
      next_grid_row = 0
      trip.stoppings.each_with_index do |stopping, i|
        stop = stopping.stop
        time = stopping.arrival_time
        pos = stopping.position
        if i == 0 && !@first_stops.include?(stop)
          @first_stops << stop
        end
        time = time.split(':')[0,2].join(':')
        stop_row = @grid.detect {|x| x.is_a?(Hash) && x[:stop] && x[:stop][:stop_id] == stop.id}
        if stop_row
          stop_row[:times][col] = time
          next_grid_row = @grid.index(stop_row) + 1
        else
          values = Array.new(@trips.size)
          values[col] = time
          stop_id = stop.id
          name = stop.name
          lat = stop.lat
          lng = stop.lng
          hash = {:stop_id => stop_id, :name => name, :lat => lat.to_f, :lng => lng.to_f}
          stop_row = {:stop => hash, :times => values}
          @grid.insert(next_grid_row, stop_row)
          next_grid_row += 1
        end
      end
    end

    @grid
  end

  def next_arrivals_for_stops(trips)
    result = ActiveRecord::Base.connection.select_all("select stoppings.stop_id, group_concat(stoppings.arrival_time, '|', stoppings.trip_id) as arrival_times from stoppings " + 
      "where stoppings.trip_id in (#{trips.map(&:id).join(',')}) " + 
      "group by stoppings.stop_id")
    # each arrival time has this format:
    # 16:21:00|49739
    # the second number is the trip id

    data = result.inject({}) do |memo, hash|
      stop_id = hash["stop_id"].to_i
      arrival_times = hash["arrival_times"].
        split(',').
        map {|x| x.split('|')}.  # split into arrival time and trip id number
        sort. # normally, we would limit the number here, but not now since we allow user to shift grid
        map {|x| 
          #@ordered_trip_ids << x[1] unless @ordered_trip_ids.include?(x[1])
          [format_time(x[0]),x[1].to_i] }
      if !arrival_times.empty?
        memo[stop_id] = arrival_times
      end
      memo
    end
    #logger.debug "ALL NEXT ARRIVALS: #{data.inspect}"
    data
  end

end
