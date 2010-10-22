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
        if params[:version] == "2" || params[:version] == "3"
          @first_stop = params[:first_stop]
          if @first_stop == "(null)"
            @first_stop = nil
          end
          @result = NewTripSet.new(:offset => params[:offset], 
                                   :limit => 10,
                                   :headsign => (@headsign = params[:headsign].gsub(/\^/, "&")) , 
                                   :first_stop => @first_stop,
                             :route_short_name => (@route = params[:route_short_name]),
                             :now => Now.new(base_time),
                             :transport_type => (@transport_type = params[:transport_type].downcase.gsub(" ", "_").to_sym)).result

          if @transport_type == :bus && (base_time < 2.minutes.from_now && base_time > 2.minutes.ago)
            @result = RealTime.add_data(@result, :headsign => @headsign, :route_short_name => @route)
          elsif @transport_type == :subway && params[:version] == '3' && @route !~ /Green/
            @result = SubwayRealTime.add_data(@result, :headsign => @headsign, :route_short_name => @route, :first_stop => @first_stop)
          end
          if @transport_type == :subway
            @first_stop = nil
          end
       
          if params[:version] == '3'
            logger.debug("ADDING GRID")

            cache_key = URI.escape("#{@transport_type}:#{@route}:#{@headsign}:#{@first_stop}")
            # cache this
            grid = cache(cache_key, :expires_in => 3.hours) do
              logger.debug "CACHING: #{cache_key}"
              Grid.new(@transport_type.to_s, @route, @headsign, @first_stop).grid
            end

            # make sure grid has same order as result
=begin
            if @result[:ordered_stop_ids]
              final_grid = []
              @result[:ordered_stop_ids].each do |x|
                final_grid << grid.detect {|y| y[:stop][:stop_id].to_s == x.to_s}
              end
            else
              final_grid = grid
            end
=end


            # sync up stops between grid and stops dictionary
            if @result[:stops] && !@result[:stops].empty?

              @result[:ordered_stop_ids] = grid.compact.map {|row| row[:stop][:stop_id]}
              grid.compact.each {|stop| 
                next if @result[:stops].nil?
                next if stop[:stop].nil?
                next if @result[:stops][stop[:stop][:stop_id]] 
                x  = Stop.find(stop[:stop][:stop_id])
                # TODO add next arrivals from grid! 
                additional_stop = {:name => stop[:stop][:name], :lat => x.lat, :lng => x.lng}
                @result[:stops][stop[:stop][:stop_id]] = additional_stop
              }

            end


            # mark times that are past
            grid.each do |stop|
              stop[:times] = stop[:times].map do |time|
                next if time.nil?
                time = time.split(':')[0,2].join(':')
                hour, min = time.split(':')[0,2]
                now_hour = Time.now.hour
                if now_hour < 3 # 24 hour clock, 1 am
                  now_hour = now_hour + 24
                end
                now_string = [ "%.2d" % now_hour, "%.2d" % Time.now.min].join(":")

                if time < now_string 
                  time = [format_time(time), -1]
                else
                  time = [format_time(time), 1]
                end
              end
            end
#            logger.debug final_grid.inspect
            @result.merge!(:grid => grid.compact)
          end
          
          # @result.merge!(:ads => "iAds") # controls whether iAds are shown
#          if rand(5) == 0 
#            logger.info "Adding ipad available message"
#            @result.merge!({:message => {:title => "OpenMBTA is now available on the iPad", :body => "Download the 1.0 iPad version today."}})
#          end
          logger.info "USER AGENT: #{request.headers['User-Agent']}"
 

        else # first version
          @result = TripSet.new(:headsign => (@headsign = params[:headsign].gsub(/\^/, "&")) , 
                               :route_short_name => (@route = params[:route_short_name]),
                               :transport_type => (@transport_type = params[:transport_type].downcase.gsub(" ", "_").to_sym),
                               :now => Now.new(base_time)).result
        end
        
        if params[:version] == "2" && rand(3) == 0
          @result.merge!({:message => {:title => "New Version Available", :body => "Please upgrade to OpenMBTA 1.3 when you get the chance"}})
        end
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
                                 :first_stop => (@first_stop = params[:first_stop]),
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


  def realtime
  
        chunks = CGI.unescape(request.query_string).gsub(/ & /, " ^ ").split("&")
        headsign_param = chunks.detect {|x| x =~ /^headsign=/}
        if headsign_param
          @headsign = headsign_param.split(/=/)[1]
          logger.debug("@headsign: #@headsign")
        end

        @result = NewTripSet.new(:offset => params[:offset], 
                                 :headsign => (@headsign ||= params[:headsign]).gsub(/\^/, "&"), 
                                 :first_stop => (@first_stop = params[:first_stop]),
                           :route_short_name => (@route = params[:route_short_name]),
                           :now => Now.new,
                           :transport_type => (@transport_type = params[:transport_type].downcase.gsub(" ", "_").to_sym)).result

        if @result[:message]
          render :text => @result[:message][:body]
          return
        end
        @current_offset = params[:offset] ? params[:offset].to_i : 0
        @trip_ids = @result[:ordered_trip_ids]

        @cols = 6



        @region = @result[:region]
        @center_lat = @region[:center_lat]
        @center_lng = @region[:center_lng]
        lat_span = @region[:lat_span] * 0.3
        lng_span = @region[:lng_span] * 0.3
        @sw = [@region[:center_lat] - lat_span, @region[:center_lng] - lng_span]
        @ne = [@region[:center_lat] + lat_span, @region[:center_lng] + lng_span]
        @stops = @result[:stops].map {|k,v| v[:stop_id] = k; v}

          if @transport_type == :bus 
            @result = RealTime.add_data(@result, :headsign => @headsign, :route_short_name => @route)
          elsif @transport_type == :subway && params[:version] == '3'
            @result = SubwayRealTime.add_data(@result, :headsign => @headsign, :route_short_name => @route, :first_stop => @first_stop)
          end
  end
end
