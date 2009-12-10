require 'json_printer'

class TripsController < ApplicationController
  layout 'mobile'
  include TimeFormatting
  def index
    base_time = params[:base_time] ? Time.parse(params[:base_time]) : Time.now

    # pass in options[:now] to set different base time
    @result = TripSet.new(:headsign => (@headsign = params[:headsign].gsub(/\^/, "&")) , 
                       :route_short_name => (@route = params[:route_short_name]),
                       :transport_type => (@transport_type = params[:transport_type].downcase.gsub(" ", "_").to_sym),
                       :now => Now.new(base_time)).result
    respond_to do |format|
      format.json { 
        render :json => @result.to_json
      }
      format.html { 
        @region = @result[:region]
        @center_lat = @region[:center_lat]
        @center_lng = @region[:center_lng]
        lat_span = @region[:lat_span] * 0.3
        lng_span = @region[:lng_span] * 0.3
        @sw = [@region[:center_lat] - lat_span, @region[:center_lng] - lng_span]
        @ne = [@region[:center_lat] + lat_span, @region[:center_lng] + lng_span]
        @stops = @result[:stops].map {|k,v| v[:stop_id] = k; v}

      }
    end
  end
end
