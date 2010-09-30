class AboutController < ApplicationController
  layout 'iphone_layout'

  def index
    render :layout => 'mobile'
  end

  def mobile_version
    render :layout => 'mobile'
  end
end
