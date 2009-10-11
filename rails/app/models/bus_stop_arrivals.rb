module BusStopArrivals
  def self.arrivals(stopping_id, options)
    headsign = options[:headsign]
    route_ids = Route.all(:conditions => {:short_name => options[:route_short_name]}).map(&:id)

    Stopping.all(
      :joins => "inner join trips on trips.id = stoppings.trip_id",
      :conditions => ["stoppings.stop_id = ? and trips.route_id in (?) and " + 
        "trips.service_id in (?) and trips.headsign = ? " +
        "and stoppings.arrival_time > '#{Now.time}'", stopping_id, route_ids, Service.ids_active_today, headsign],
      :order => "stoppings.arrival_time asc"
    )
  end
end
