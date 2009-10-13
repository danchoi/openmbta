# This class takes a commuter rail route short name and then returns a list of
# all the train numbers. This special case is dealt separately is because the
# train stop structure is so irregular.
class TrainsController < ApplicationController

  def index
    line_name = params[:line_name]
    line_headsign = params[:line_headsign]
    @result = CommuterRail.trains(line_name, line_headsign, Now.new)
    if @result.empty?
      render :json => {:message => {:title => "Alert", :body => "No more trips for the day"}}.to_json
    else
      render :json => {:data => @result}.to_json
    end

  end

end
