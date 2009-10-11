module CommuterRailStopArrivals

  # the data i have to work with:
  # {"headsign"=>"Forge Park / 495", "stop_id"=>"8457",
  # "route_short_name"=>"Franklin", "transport_type"=>"Commuter Rail"}
  def self.arrivals(stopping_id, options)
    route_short_name = "CR-#{options[:route_short_name]}"
    route_id = Route.find_by_mbta_id(route_short_name)

    Stopping.all(
      :joins => "inner join trips on trips.id = stoppings.trip_id",
      :conditions => ["stoppings.stop_id = ? and trips.route_id = ? and " + 
        "trips.service_id in (?) and trips.headsign LIKE ? " +
        "and stoppings.arrival_time > '#{Now.time}'", stopping_id, route_id, Service.ids_active_today, "#{options[:headsign]}%"],
      :order => "stoppings.arrival_time asc"
    )

  end
end
