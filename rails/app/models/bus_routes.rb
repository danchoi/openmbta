module BusRoutes
  def self.routes(service_ids)
    ActiveRecord::Base.connection.select_all("select case when routes.short_name = ' ' then 'Other' else routes.short_name end route_short_name, trips.headsign from routes inner join trips on trips.route_id = routes.id where routes.route_type in (3) and trips.service_id in (#{service_ids.join(',')}) group by routes.short_name, trips.headsign").
      group_by {|r| r["route_short_name"]}.
      map {|short_name, values| {:route_short_name => short_name, 
          :headsigns => values.map {|x| 
            x["headsign"] 
          } 
        } 
      }.
      sort_by {|x| x[:route_short_name].to_i == 0 ? 10000 : x[:route_short_name].to_i }
  end
end
