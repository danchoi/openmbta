class HelpController < ApplicationController
  layout 'iphone_layout'

  def show
    @transport_type = params[:transport_type] || "bus"
  end

end
