class StopArrivalsController < ApplicationController

  def index
    stop = Stop.find params[:stop_id]
    result  = stop.arrivals(:route_short_name => params[:route_short_name],
                            :headsign => params[:headsign].gsub(/\^/, "&"),
                            :transport_type => params[:transport_type].downcase.gsub(' ', '_').to_sym)


    render :json => result.to_json
  end

end
