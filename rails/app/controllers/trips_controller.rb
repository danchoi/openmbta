require 'json_printer'
require 'enumerator'

class TripsController < ApplicationController
  layout 'mobile'
  include TimeFormatting
  def index
    base_time = params[:base_time] ? Time.parse(params[:base_time]) : Time.now

    respond_to do |format|
      format.json { 
        # pass in options[:now] to set different base time
        if params[:version] == "2"
          @result = NewTripSet.new(:offset => params[:offset], 
                                   :limit => 10,
                                   :headsign => (@headsign = params[:headsign].gsub(/\^/, "&")) , 
                                   :first_stop => params[:first_stop],
                             :route_short_name => (@route = params[:route_short_name]),
                             :now => Now.new(base_time),
                             :transport_type => (@transport_type = params[:transport_type].downcase.gsub(" ", "_").to_sym)).result

          if @transport_type == :bus && (base_time < 2.minutes.from_now && base_time > 2.minutes.ago)
            logger.debug "searching for REAL TIME data"
            @result = RealTime.add_data(@result, :headsign => @headsign, :route_short_name => @route)
          end

        else # first version
          @result = TripSet.new(:headsign => (@headsign = params[:headsign].gsub(/\^/, "&")) , 
                               :route_short_name => (@route = params[:route_short_name]),
                               :transport_type => (@transport_type = params[:transport_type].downcase.gsub(" ", "_").to_sym),
                               :now => Now.new(base_time)).result
        end

        logger.debug @result.to_json
        #File.open("#{Rails.root}/realtime/temp.yml", 'w') {|f| f.write( @result.to_yaml )}
        render :json => @result.to_json
      }

      # FOR MOBILE WEB
      #
      format.html { 

        chunks = CGI.unescape(request.query_string).gsub(/ & /, " ^ ").split("&")
        headsign_param = chunks.detect {|x| x =~ /^headsign=/}
        if headsign_param
          @headsign = headsign_param.split(/=/)[1]
          logger.debug("@headsign: #@headsign")
        end

        @result = NewTripSet.new(:offset => params[:offset], 
                                 :headsign => (@headsign ||= params[:headsign]).gsub(/\^/, "&"), 
                                 :first_stop => params[:first_stop],
                           :route_short_name => (@route = params[:route_short_name]),
                           :now => Now.new(base_time),
                           :transport_type => (@transport_type = params[:transport_type].downcase.gsub(" ", "_").to_sym)).result

        if @result[:message]
          render :text => @result[:message][:body]
          return
        end
        @current_offset = params[:offset] ? params[:offset].to_i : 0
        @trip_ids = @result[:ordered_trip_ids]
        @trip_sets = [] 
        @cols = 6
        @trip_ids.each_slice(@cols) do |trip_set|
          @trip_sets << trip_set
        end

        @region = @result[:region]
        @center_lat = @region[:center_lat]
        @center_lng = @region[:center_lng]
        lat_span = @region[:lat_span] * 0.3
        lng_span = @region[:lng_span] * 0.3
        @sw = [@region[:center_lat] - lat_span, @region[:center_lng] - lng_span]
        @ne = [@region[:center_lat] + lat_span, @region[:center_lng] + lng_span]
        @stops = @result[:stops].map {|k,v| v[:stop_id] = k; v}

        if params[:version] == "3"

          render :action => "index3"
        end
      }
    end
  end
end
