require 'json_printer'

class TripsController < ApplicationController
  include TimeFormatting
  def index
    @date = params[:date] || Date.today.to_s
    @result = Trip.for(:date => @date, 
                       :headsign => params[:headsign].gsub(/\^/, "&") , 
                       :route_short_name => params[:route_short_name],
                       :transport_type => params[:transport_type].downcase.gsub(" ", "_").to_sym)
    render :json => @result.to_json
  end

  def show
    @result = Trip.for(:trip_id => params[:id], :from_position => params[:from_position].to_i)
    render :json => @result.to_json
  end
end
