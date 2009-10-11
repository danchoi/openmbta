module CommuterRailRoutes
  def self.routes(service_ids)
    results = ActiveRecord::Base.connection.select_all("select routes.mbta_id, trips.headsign, count(trips.id) as trips_remaining from routes inner join trips on routes.id = trips.route_id where trips.route_type = 2 and trips.end_time > '#{Now.time}' and trips.service_id in (#{service_ids.join(',')}) group by trips.headsign order by mbta_id asc;").
      group_by {|r| r["mbta_id"]}.
      map { |route_mbta_id, values| { :route_short_name  =>  route_mbta_id.sub(/CR-/, ''), :headsigns => generate_headsigns(values) }}
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
