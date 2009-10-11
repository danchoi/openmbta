module CommuterRailTrips

  def self.trips(options)
    route_short_name = "CR-#{options[:route_short_name]}"
    headsign = options[:headsign]

    Trip.all(:joins => :route,
             :conditions => ["routes.mbta_id = ? and headsign LIKE ? and service_id in (?) and end_time > '#{Now.time}'", route_short_name, "#{headsign}%", Service.ids_active_today], 
             :order => "start_time asc", 
             :limit => options[:limit] || 10)
  end

end
