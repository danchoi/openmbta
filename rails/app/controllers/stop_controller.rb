class StopController < ApplicationController

  def show
    @stop = Stop.find params[:id]
    @trips = Trip.find(params[:trip_ids].split(','))
    @subroute = SubRoute.new(params[:headsign], @trips)
  end
end
