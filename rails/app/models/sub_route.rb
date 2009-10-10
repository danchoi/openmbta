class SubRoute
  include Haversine
  attr_accessor :headsign, :trips, :trip_ids

  def initialize(headsign, trips)
    @headsign = headsign
    @trips = trips
    @trip_ids = @trips.map(&:id)
  end

  def print_trips
    @trips.map {|t| TripPrinter.new(t)}
  end

  def stoppings(stop_name=nil)
    if stop_name.nil?
      stop_name = stops.first.name
    end
    stoppings(stop_name)
  end

  def stops
    # take the first trip as representative
    @stops ||= Stop.all(:select => "stops.*, stoppings.position as position",
      :joins => "inner join stoppings on stops.id = stoppings.stop_id",
      :conditions => ["stoppings.trip_id = ?", @trip_ids.first],
      :order => "stoppings.position asc")
  end

  def stop_names
    stops.map(&:name)
  end

  def haversines
    return @haversines if @haversines
    @first_stop = stops.first
    @haversines ||= stops.map do |stop|
      ("%.2f" % haversine_distance(@first_stop.lat, @first_stop.lng, stop.lat, stop.lng)).to_f
    end
  end

  def stoppings(stop_name)
    Stopping.all(:joins => "inner join stops on stops.id = stoppings.stop_id",
                 :conditions => ["stops.name = ? and trip_id in (?)", stop_name, @trip_ids], 
                 :order => "arrival_time asc")
  end

  def inspect
    "<SubRoute: #{@headsign} (#{@trips.size} trips)>"
  end
end
