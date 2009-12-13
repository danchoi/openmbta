module TripsHelper

  # cell value for a stop arrival time
  def cell_value(stop_id, trip_id)
    return nil unless trip_id
    next_arrival = @result[:stops][stop_id][:next_arrivals].detect {|x| x[1] == trip_id }  
    return nil unless next_arrival
    next_arrival[0] 
  end
end
