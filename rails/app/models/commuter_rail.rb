module CommuterRail

  def self.routes(now = Now.new)
    service_ids = Service.active_on(now.date).map(&:id)
    results = ActiveRecord::Base.connection.select_all("select routes.mbta_id, trips.headsign, count(trips.id) as trips_remaining from routes inner join trips on routes.id = trips.route_id where trips.route_type = 2 and trips.end_time > '#{now.time}' and trips.service_id in (#{service_ids.join(',')}) group by trips.headsign order by mbta_id asc;").
      group_by {|r| r["mbta_id"]}.
      map { |route_mbta_id, values| { :route_short_name  =>  route_mbta_id.sub(/CR-/, ''), :headsigns => generate_headsigns(values) }}
  end

  def self.trips(options)
    now = options[:now] || Now.new
    route_short_name = "CR-#{options[:route_short_name]}"
    headsign = options[:headsign]

    Trip.all(:joins => :route,
             :conditions => ["routes.mbta_id = ? and headsign LIKE ? and service_id in (?) and end_time > '#{now.time}'", route_short_name, "#{headsign}%", Service.ids_active_on(now.date)], 
             :order => "start_time asc", 
             :limit => options[:limit] || 10)
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
        "and stoppings.arrival_time > '#{now.time}'", stopping_id, route_id, Service.ids_active_on(now.date), "#{options[:headsign]}%"],
      :order => "stoppings.arrival_time asc"
    )

  end

  def self.generate_headsigns(values)
    headsigns = Hash.new(0)
    values.each do |value|
      headsign = value['headsign'].gsub(/\s\(Train [^)]+\)/, '')
      headsigns[headsign] += value['trips_remaining'].to_i
    end
    headsigns.to_a
  end

end
