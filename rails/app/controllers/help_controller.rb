class HelpController < ApplicationController
  layout 'mobile'

  def show
    @transport_type = params[:transport_type] || "bus"
    if ['subway', 'commuter rail'].include? @transport_type.downcase 
      @transport_type = @transport_type + ' train'
    end
  end

end
