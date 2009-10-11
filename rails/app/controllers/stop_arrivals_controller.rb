class StopArrivalsController < ApplicationController
  include TimeFormatting

  def index
    stop = Stop.find params[:stop_id]
    stoppings = stop.arrivals(:route_short_name => params[:route_short_name],
                              :headsign => params[:headsign].gsub(/\^/, "&"))

    # TODO add number of subsequent stops on trip
    result = stoppings.map {|stopping|
      trip = stopping.trip
      {
        :arrival_time => format_time(stopping.arrival_time),
        :trip_id => stopping.trip_id,
        :more_stops => trip.num_stops - stopping.position,
        :last_stop => trip.last_stop
      }
    }
    render :json => result.to_json
  end

end
