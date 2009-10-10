require 'json_printer'

class TripsController < ApplicationController
  def index
    @date = params[:date] || Date.today.to_s
    # This is a hack because we sometime need to include an ampersand in the headsign and Rails
    # splits params on ampersands, even escaped ones.
    @headsign = params[:headsign].gsub(/\^/, "&") 

    @route_ids = if params[:route_id]
                  params[:route_id].split(',')
                else
                  Route.all(:conditions => {:short_name => params[:route_short_name]}).map(&:id)
                end

    @result = Trip.for(:date => @date, :headsign => @headsign, :route_id => @route_ids)

    #render :json => JsonPrinter.render(@result)
    render :json => @result.to_json
  end

  def show
    @trip = Trip.find(params[:id])
  end
end
