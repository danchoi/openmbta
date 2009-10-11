module CommuterRailRoutes
  def self.routes(service_ids)
    results = ActiveRecord::Base.connection.select_all("select routes.mbta_id, trips.headsign from routes inner join trips on routes.id = trips.route_id where trips.route_type = 2 group by trips.headsign order by mbta_id asc;").
      group_by {|r| r["mbta_id"]}.
      map { |route_mbta_id, values| { :route_short_name  =>  route_mbta_id.sub(/CR-/, ''), 
        :headsigns => values.map {|value| value['headsign'].gsub(/\s\(Train [^)]+\)/, '')}.uniq.sort
      }}
  end
end
