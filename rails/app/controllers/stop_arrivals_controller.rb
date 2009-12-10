class StopArrivalsController < ApplicationController
  layout 'mobile'

  def show
  end

  def index
    base_time = params[:base_time] ? Time.parse(params[:base_time]) : Time.now
    @stop = Stop.find params[:stop_id]

    # pass in options[:now] to set different base time
    @result = TripSet.new(:headsign => (@headsign = params[:headsign].gsub(/\^/, "&")) , 
                       :route_short_name => (@route = params[:route_short_name]),
                       :transport_type => params[:transport_type].downcase.gsub(" ", "_").to_sym,
                       :now => Now.new(base_time)).result

    @region = @result[:region]
    @center_lat = @region[:center_lat]
    @center_lng = @region[:center_lng]
    @stops = @result[:stops].map {|k,v| v[:stop_id] = k; v}

    @arrivals = @stop.arrivals(params)
  end

end
