class RoutesController < ApplicationController

  # This doesn't really return routes, but route short_names and headsigns
  def index
    transport_types = case params[:transport_type]
                      when "bus"
                        3
                      when "subway"
                        [0,1]
                      when "commuter_rail"
                        2
                      else
                        4
                      end
    @result = Route.routes(transport_types)
    render :json => @result.to_json
  end
end
