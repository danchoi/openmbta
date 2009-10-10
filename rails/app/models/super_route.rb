require 'set'

class SuperRoute 
  include Comparable
  attr_accessor :route_ids # internal ids
  attr_accessor :routes
  attr_accessor :short_name

  def self.all_names
    Route.connection.select_values("select distinct(short_name) from routes where short_name is not null and short_name != ''") 
  end

  def self.all
    all_names.map do |name|
      self.new(name)
    end
  end    

  def self.all_for_type(type)
    Route.connection.select_values("select distinct(short_name) from routes where short_name is not null and short_name != '' and route_type = #{type}").
      map {|name| self.new(name)}.
      select {|x| !x.subroutes.empty?}.
      sort
  end

  def initialize(short_name, params={})
    @short_name = short_name.to_s
    @routes = Route.all(:conditions => ["short_name = ?", @short_name])
    @route_ids = @routes.map {|r| r.id}
    @date = parse_date(params[:date] || Date.today.to_s)
    @schedule_type = params[:schedule_type] || 'weekday'
  end

  # Returns Subroutes
  def subroutes
    conditions = ["? between service_start_date and service_end_date ", @date]

    # TODO override here if the date is a holiday and there is a holiday service for this route
    # also check if trips are doubled

    conditions[0] << " and schedule_type = ?"
    conditions << @schedule_type
    
    # group into subroutes
    split_into_subroutes(trips(:conditions => conditions)) 
  end

  def route_stops
    # to make fast, assume the first trip of each underlying route is representative
    trips.inject(Set.new) do |stops, trip| 

      trip.stops.each do |stop|
        stops << stop
      end

      stops
    end.sort_by {|s| s.name}
  end

  # Wrap this in other convenience methods
  def trips(options={}, &block)
    return @trips if @trips
    conditions = options[:conditions] 
    if conditions 
      if conditions.is_a?(String)
        conditions = [conditions]
      end
      conditions[0] << " and route_id in (?)"
      conditions << @route_ids
    end
    options[:conditions] = conditions
    options[:order] = "start_time asc"
    @trips = Trip.all(options)
  end

  def split_into_subroutes(ungrouped_trips)
    ungrouped_trips.group_by(&:headsign).map do |headsign, group|
      SubRoute.new(headsign, group)
    end
  end

  def <=>(other) 
    if self.short_name =~ /^\d/ && other.short_name =~ /^\d/
      self.short_name.to_i <=> other.short_name.to_i
    else
      self.short_name <=> other.short_name
    end
  end 

  def parse_date(x)
    if x.is_a?(Date)
      return x
    else
      parsed = ParseDate.parsedate(x)[0,3]
      Date.new(*parsed)
    end
  end


  def inspect
    "<#{self.class.to_s} #{short_name} (#{self.routes.first.transport_type}) (#{self.subroutes.size} routes)\n  #{self.subroutes.map {|r| r.headsign }.join("\n  ")}>"
  end
end
