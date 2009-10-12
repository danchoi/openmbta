class RoutesController < ApplicationController

  # This doesn't really return routes, but route short_names and headsigns
  def index
    transport_type = params[:transport_type].downcase.gsub(' ', "_").to_sym
    @result = Route.routes(transport_type)
    render :json => {:data => @result}.to_json
  end
end
