module Bus

  def self.routes(now = Now.new)
    service_ids = Service.active_on(now.date).map(&:id)
    ActiveRecord::Base.connection.select_all("select case when routes.short_name = ' ' then 'Other' else routes.short_name end route_short_name, trips.headsign, count(trips.id) as trips_remaining from routes inner join trips on trips.route_id = routes.id where routes.route_type in (3) and trips.service_id in (#{service_ids.join(',')}) and trips.end_time > '#{now.time}' group by routes.short_name, trips.headsign").
      group_by {|r| r["route_short_name"]}.
      select {|short_name, value|  short_name != "Shuttle" && short_name != "Other"}.
      map {|short_name, values| {:route_short_name => short_name, 
          :headsigns => values.map {|x| [x["headsign"], x["trips_remaining"].to_i] }
        } 
      }.
      sort_by {|x| 
        if x[:route_short_name].to_i == 0 
          # CT routes
          digit = x[:route_short_name][/(\d)/, 1]
          10000 + digit.to_i
        else
          x[:route_short_name].to_i
        end
      }
  end

  def self.trips(options)
    now = options[:now] || Now.new
    date = now.date
    route_short_name = options[:route_short_name]
    headsign = options[:headsign]
    service_ids = Service.active_on(date).map(&:id)
    now = now.time

    Trip.all(:joins => :route,
             :conditions => ["routes.short_name = ? and headsign = ? and service_id in (?) and end_time > '#{now}'", route_short_name, headsign, service_ids], 
             :order => "start_time asc", 
             :limit => options[:limit])
  end

  def self.arrivals(stopping_id, options)
    now = options[:now] || Now.new
    headsign = options[:headsign]
    route_ids = Route.all(:conditions => {:short_name => options[:route_short_name]}).map(&:id)

    Stopping.all(
      :joins => "inner join trips on trips.id = stoppings.trip_id",
      :conditions => ["stoppings.stop_id = ? and trips.route_id in (?) and " + 
        "trips.service_id in (?) and trips.headsign = ? " +
        "and stoppings.arrival_time > '#{now.time}'", stopping_id, route_ids, Service.ids_active_on(now.date), headsign],
      :order => "stoppings.arrival_time asc"
    )
  end

  def self.silver_line_route_ids
    ActiveRecord::Base.connection.select_all("select distinct(route_id) from trips where first_stop like 'So Station Silver Line%' or last_stop like 'So Station Silver Line%' or last_stop = 'Essex St @ Atlantic Ave' or last_stop like 'Silver Line Way%'").map {|hash| hash["route_id"].to_i}
  end

  def self.populate_silver_lines
    # populates routes.short_names of SILVER_LINE routes
    silver_line_route_ids.each do |route_id|
      puts "adding short name to route #{route_id}"
      Route.find(route_id).update_attribute(:short_name, "SL")
    end
    # fix the headsigns
    Trip.all(:conditions => "first_stop = 'Terminal A'").each do |trip|
      trip.update_attribute :headsign, "SL1 - South Station"
    end
    Trip.all(:conditions => "last_stop = 'Terminal A'").each do |trip|
      trip.update_attribute :headsign, "SL1 - Logan Airport"
    end
    Trip.all(:conditions => "last_stop = 'Dry Dock Ave @ Design Center Place'").each do |trip|
      trip.update_attribute :headsign, "SL2 - Design Center"
    end
    Trip.all(:conditions => "first_stop = 'Dry Dock Ave @ Design Center Place'").each do |trip|
      trip.update_attribute :headsign, "SL2 - South Station"
    end
    Trip.all(:conditions => "first_stop = 'Essex St @ Atlantic Ave'").each do |trip|
      trip.update_attribute :headsign, "SL4 - South Station"
    end
    Trip.all(:conditions => "last_stop = 'Essex St @ Atlantic Ave'").each do |trip|
      trip.update_attribute :headsign, "SL4 - Dudley Station"
    end
    Trip.all(:conditions => "first_stop = 'Temple Place @ Washington St'").each do |trip|
      trip.update_attribute :headsign, "SL5 - Downtown"
    end
    Trip.all(:conditions => "last_stop = 'Temple Place @ Washington St'").each do |trip|
      trip.update_attribute :headsign, "SL5 - Dudley Station"
    end
    Trip.all(:conditions => "first_stop like 'Silver Line Way before%'").each do |trip|
      trip.update_attribute :headsign, "Silver Line Way (inbound)"
    end
    Trip.all(:conditions => "last_stop = 'Silver Line Way after Manulife Building'").each do |trip|
      trip.update_attribute :headsign, "Silver Line Way (outbound)"
    end
  end
end
