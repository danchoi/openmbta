class AlertsController < ApplicationController

  def index
    alerts = Alert.all(:limit => 20, :order => "pub_date  desc")

    render :json => {:data => alerts}
  end

  def show
    @alert = Alert.find_by_guid params[:guid]
    render :layout => 'iphone_layout'
  end


end
