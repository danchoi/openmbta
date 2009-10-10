class TripPrinter

  def initialize(trip)
    @trip = trip
  end

  def inspect
    "[#{@trip.id}] #{@trip.first_stop} #{@trip.start_time} -> #{@trip.last_stop} #{@trip.end_time} (#{@trip.num_stops} stops)"
  end
end
