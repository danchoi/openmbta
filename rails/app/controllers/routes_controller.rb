class RoutesController < ApplicationController

  # This doesn't really return routes, but route short_names and headsigns
  def index
    transport_type = params[:transport_type].downcase.gsub(' ', "_").to_sym
    @result = Route.routes(transport_type)
    if @result.empty?
      render :json => {:message => {:title => "Alert", :body => "No more trips for the day"}}.to_json
    else
      render :json => {:data => @result}.to_json
    end
  end
end
