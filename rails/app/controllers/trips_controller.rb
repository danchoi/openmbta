require 'json_printer'

class TripsController < ApplicationController
  include TimeFormatting
  def index
    base_time = Time.parse(params[:base_time])

    if (2.minutes.ago..2.minutes.from_now) === base_time # wiggle room, not sure if we need this
      base_time = Time.now
    end

    # pass in options[:now] to set different base time
    @result = TripSet.new(:headsign => params[:headsign].gsub(/\^/, "&") , 
                       :route_short_name => params[:route_short_name],
                       :transport_type => params[:transport_type].downcase.gsub(" ", "_").to_sym,
                       :now => Now.new(base_time)).result
    respond_to do |format|
      format.json { 
        render :json => @result.to_json
      }
      format.html { 
        render :layout => false
      }
    end
  end
end
