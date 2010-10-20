class RoutesController < ApplicationController
  layout 'mobile'

  # This doesn't really return routes, but route short_names and headsigns
  def index
    @transport_type = params[:transport_type].downcase.gsub(' ', "_").to_sym
    cache_key = "routesFor:#{@transport_type.to_s}"
    @result = cache(cache_key, :expires_in => 4.minutes) do
      if @transport_type == :subway 
        Route.new_routes(@transport_type, Now.new)
      else 
        Route.routes(@transport_type, Now.new)
      end
    end

#    if @transport_type == :bus
#      logger.debug @result.inspect
#    end
    respond_to do |format|

      format.json {
        if @result.empty?
          render :json => {:message => {:title => "Alert", :body => "No more trips for the day"}}.to_json
        else
          render :json => {:data => @result}.to_json
        end
      }

      format.html { }

    end
  end
end
