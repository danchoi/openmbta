module Subway

  ROUTE_NAME_TO_MBTA_ID = {
    "Green Line" => %w{810 811 812 822 830 831 852 880 881},
    "Red Line" => %w{931 933},
    "Blue Line" => %w{946 948 9462 899},
    "Orange Line" => %w{903 913} 
  }

  # Looks like this after generation:
  #
  # {"Green Line"=>[957, 959, 961, 963, 965, 967, 978, 992, 994], "Blue
  # Line"=>[1039, 1041], "Orange Line"=>[1011, 1017], "Red Line"=>[1027, 1033]}
  ROUTE_NAME_TO_ID = ROUTE_NAME_TO_MBTA_ID.inject({}) do |memo, pair|
    line_name, numbers = pair
    ids = numbers.map {|number| 
      route = Route.first(:conditions => ["route_type in (0,1) and mbta_id like ?", "#{number}%"])
      route.id
    }
    memo[line_name] = ids
    memo
  end

  # Looks like this after generation::
  #
  # {1039=>"Blue Line", 1017=>"Orange Line", 957=>"Green Line", 963=>"Green
  # Line", 1041=>"Blue Line", 992=>"Green Line", 959=>"Green Line", 965=>"Green
  # Line", 1027=>"Red Line", 994=>"Green Line", 961=>"Green Line", 1033=>"Red
  # Line", 978=>"Green Line", 967=>"Green Line", 1011=>"Orange Line"}
  ROUTE_ID_TO_NAME = ROUTE_NAME_TO_ID.inject({}) do |memo, pair|
    line_name, route_ids = pair[0], pair[1]
    route_ids.each {|route_id| 
      memo[route_id] = line_name
    }
    memo
  end

  def self.routes(now = Now.new)
    service_ids = Service.active_on(now.date).map(&:id)
    results = ActiveRecord::Base.connection.select_all("select routes.id as route_id, trips.headsign, count(trips.id) as trips_remaining from routes inner join trips on routes.id = trips.route_id where trips.route_type in (0,1) and trips.end_time > '#{now.time}' and trips.service_id in (#{service_ids.join(',')}) group by trips.headsign;").
      group_by {|r| ROUTE_ID_TO_NAME[r["route_id"].to_i]}.
      map { |route_name, values| { :route_short_name  =>  route_name, :headsigns => generate_headsigns(values) }}
  end


  # [{"route_short_name":"Red
  # Line","headsigns":[["Alewife",10],["Braintree",5]]},{"route_short_name":"Blue
  # Line","headsigns":[["Ashmont",11],["Bowdoin",4],["Mattapan",7],["Wonderland",6]]},{"route_short_name":"Green
  # Line","headsigns":[["B - Boston College",11],["C - Cleveland Circle",10],["D
  # - Riverside",9],["E - Heath Street",7],["Government
  # Center",12],["Lechmere",9],["North Station",6]]},{"route_short_name":"Orange
  # Line","headsigns":[["Forest Hills",6],["Oak Grove",5]]}]hellenic
  # ~/MBTA/rails:
  def self.trips(options)
    now = options[:now] || Now.new
    date = now.date
    route_short_name = options[:route_short_name]
    route_ids = ROUTE_NAME_TO_ID[route_short_name]
    headsign = options[:headsign]
    service_ids = Service.active_on(date).map(&:id)
    now = now.time

    Trip.all(:joins => :route,
             :conditions => ["routes.id in (?) and headsign = ? and service_id in (?) and end_time > '#{now}'", route_ids, headsign, service_ids], 
             :order => "start_time asc", 
             :limit => options[:limit] || 10)
  end

  def self.arrivals(stopping_id, options)
    now = options[:now] || Now.new
    headsign = options[:headsign]
    route_ids = ROUTE_NAME_TO_ID[options[:route_short_name]]

    Stopping.all(
      :joins => "inner join trips on trips.id = stoppings.trip_id",
      :conditions => ["stoppings.stop_id = ? and trips.route_id in (?) and " + 
        "trips.service_id in (?) and trips.headsign = ? " +
        "and stoppings.arrival_time > '#{now.time}'", stopping_id, route_ids, Service.ids_active_on(now.date), headsign],
      :order => "stoppings.arrival_time asc"
    )
  end

  def self.generate_headsigns(values)
    values.map {|x| [x["headsign"], x["trips_remaining"].to_i] }
  end

end
