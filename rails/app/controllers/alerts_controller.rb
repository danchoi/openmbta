class AlertsController < ApplicationController
  layout 'mobile'

  def index
    @alerts = Alert.all(:limit => 40, :order => "pub_date  desc")

    respond_to do |format|
      format.json {
        render :json => {:data => @alerts}
      }
      format.html {

      }
    end
  end

  def show
    @alert = Alert.find_by_guid params[:guid]
    render :layout => 'iphone_layout'
  end


end
