class AlertsController < ApplicationController

  def index
    render :json => Alert.all(:limit => 20, :order => "pub_date  desc").to_json
  end

end
