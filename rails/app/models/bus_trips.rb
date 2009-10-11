module BusTrips

  def self.trips(options)
    date = Now.date
    route_short_name = options[:route_short_name]
    headsign = options[:headsign]
    service_ids = Service.active_on(date).map(&:id)
    now = Now.time

    Trip.all(:joins => :route,
             :conditions => ["routes.short_name = ? and headsign = ? and service_id in (?) and end_time > '#{now}'", route_short_name, headsign, service_ids], 
             :order => "start_time asc", 
             :limit => options[:limit] || 10)
  end
end
