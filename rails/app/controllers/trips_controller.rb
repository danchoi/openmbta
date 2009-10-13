require 'json_printer'

class TripsController < ApplicationController
  include TimeFormatting
  def index
    # TODO fix for am hours
    @result = Trip.for(:headsign => params[:headsign].gsub(/\^/, "&") , 
                       :route_short_name => params[:route_short_name],
                       :transport_type => params[:transport_type].downcase.gsub(" ", "_").to_sym)
    render :json => @result.to_json
  end
end
