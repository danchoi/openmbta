class AboutController < ApplicationController
  layout 'iphone_layout'

  def index
    layout => 'mobile'
  end

  def mobile_version
    render :layout => 'mobile'
  end
end
