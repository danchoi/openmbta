class GridsController < ApplicationController

  def show
    @grid = Grid.new params[:route_short_name], params[:headsign], params[:first_stop]
    render :json => @grid.grid.to_json
  end
end
