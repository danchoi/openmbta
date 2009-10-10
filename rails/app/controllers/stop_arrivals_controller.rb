class StopArrivalsController < ApplicationController

  def index
    stop = Stop.find params[:stop_id]
    stoppings = stop.arrivals(:route_route_name => params[:route_short_name],
                              :headsign => params[:headsign].gsub(/\^/, "&"))

    result = stoppings.map {|stopping|
      {
        :arrival_time => stopping.arrival_time,
        :trip_id => stopping.trip_id
      }
    }
    render :json => result.to_json
  end

end
