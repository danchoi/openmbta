require 'json_printer'

class TripsController < ApplicationController
  include TimeFormatting
  def index
    base_time = Time.parse(params[:base_time])

    if (3.minutes.ago..3.minutes.from_now) === base_time # wiggle room
      base_time = Time.now
    end

    # pass in options[:now] to set different base time
    @result = Trip.for(:headsign => params[:headsign].gsub(/\^/, "&") , 
                       :route_short_name => params[:route_short_name],
                       :transport_type => params[:transport_type].downcase.gsub(" ", "_").to_sym,
                       :now => Now.new(base_time))
    render :json => @result.to_json
  end
end
