class HeadsignsController < ApplicationController
  def show
    @headsign = *params[:id].join("/")
  end

end
