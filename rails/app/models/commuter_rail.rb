module CommuterRail
  extend TimeFormatting

  Lines = YAML::load(File.open("#{Rails.root }/lines.yml").read)

  def self.routes(now = Now.new)
    service_ids = Service.active_on(now.date).map(&:id)
    result = Lines.map do |line|
      line_data = {:route_short_name => line[:line], :headsigns => []}
      [:inbound, :outbound].each do |dir|
        mbta_id_conditions = line[dir].map {|num| "mbta_id like '%#{num}'"}.join(' OR ')
        query = <<-END
        select count(trips.id) as trips_remaining from trips where route_type = 2 and trips.service_id in (#{service_ids.join(',')}) and (#{mbta_id_conditions}) 
        and end_time > '#{now.time}'
        END
        results = ActiveRecord::Base.connection.select_all(query)
        trips_remaining = results[0]['trips_remaining']
        line_data[:headsigns] << [dir.to_s.capitalize, trips_remaining.to_i]
      end
      line_data
    end
  end

  def self.trips(options)
    now = options[:now] || Now.new
    route_short_name = options[:route_short_name]
    headsign = options[:headsign]
    service_ids = Service.ids_active_on(now.date)
    line =  Lines.detect {|x| x[:line] == route_short_name}
    return nil if line.nil?
    puts line.inspect
    trains = line[headsign.downcase.to_sym]
    puts trains.inspect
    mbta_id_conditions = trains.map {|num| "trips.mbta_id like 'CR-%-#{num}'"}.join(' OR ')
    conditions = ["(#{mbta_id_conditions}) and trips.route_type = 2 and service_id in (?) and end_time > '#{now.time}'", service_ids]
    Trip.all(:conditions => conditions,
             :order => "start_time asc", 
             :limit => options[:limit])
  end

  # the data i have to work with:
  # {"headsign"=>"Forge Park / 495", "stop_id"=>"8457",
  # "route_short_name"=>"Franklin", "transport_type"=>"Commuter Rail"}
  def self.arrivals(stopping_id, options)
    now = options[:now] || Now.new
    route_short_name = "CR-#{options[:route_short_name]}"
    route_id = Route.find_by_mbta_id(route_short_name)

    Stopping.all(
      :joins => "inner join trips on trips.id = stoppings.trip_id",
      :conditions => ["stoppings.stop_id = ? and trips.route_id = ? and " + 
        "trips.service_id in (?) and trips.headsign LIKE ? " +
        "and stoppings.arrival_time > '#{now.time}'", stopping_id, route_id, Service.ids_active_on(now.date), "#{options[:headsign].sub(/^To /, '')}%"],
      :order => "stoppings.arrival_time asc"
    )

  end

  def self.generate_headsigns(values)
    headsigns = Hash.new(0)
    values.each do |value|
      headsign = "To #{value['headsign'].gsub(/\s\(Train [^)]+\)/, '')}"
      headsigns[headsign] += value['trips_remaining'].to_i
    end
    headsigns.to_a
  end

  # Only one route_short_names , and the headsigns are the train numbers
  def self.trains(line_name, line_headsign, now = Now.new)
    service_ids = Service.active_on(now.date).map(&:id)
    route = Route.first(:conditions => {:mbta_id => "CR-#{line_name}"})

    line_headsign = line_headsign.sub(/^To /, '')
    results = Trip.all(:select => "trips.*, count(stoppings.id) as num_stops",
      :joins => "inner join stoppings on trips.id = stoppings.trip_id ",
      :conditions => ["route_id = ? and headsign like ? and trips.end_time > '#{now.time}' and trips.service_id in (#{service_ids.join(',')}) ", route.id, "#{line_headsign}%"],
      :group => "stoppings.trip_id",
      :order => "trips.start_time asc"
    ).map {|trip| ["To #{trip.headsign}", "Starts at #{format_time(trip.start_time)}; #{trip.num_stops} #{trip.num_stops == 1 ? 'stop' : 'stops'}" ] }
    result = [{:route_short_name => line_name, :headsigns => results}]
  end




end
