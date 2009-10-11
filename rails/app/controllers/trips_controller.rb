require 'json_printer'

class TripsController < ApplicationController
  include TimeFormatting
  def index
    @date = params[:date] || Date.today.to_s
    # This is a hack because we sometime need to include an ampersand in the headsign and Rails
    # splits params on ampersands, even escaped ones.
    @headsign = params[:headsign].gsub(/\^/, "&") 

    @route_ids = if params[:route_id]
                  params[:route_id].split(',')
                else
                  # Should move this into model layer, as for Stop#arrivals
                  Route.all(:conditions => {:short_name => params[:route_short_name]}).map(&:id)
                end

    @result = Trip.for(:date => @date, :headsign => @headsign, :route_id => @route_ids)
    render :json => @result.to_json
  end

  def show
    @trip = Trip.find(params[:id])
    from_position = params[:from_position]
    result = @trip.stoppings.all(:conditions => ["position >= ?", from_position.to_i]).
      map {|stopping|
        { 
          :stop_name => stopping.stop.name,
          :arrival_time => format_time(stopping.arrival_time)
        }
    }
    render :json => result.to_json
  end
end
