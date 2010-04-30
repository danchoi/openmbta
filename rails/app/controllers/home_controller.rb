class HomeController < ApplicationController

  def index
    @transport_type = "Bus"
    if params[:donated]
      flash.now[:notice] = "Thank you for your donation. I appreciate it. - Daniel Choi "
    end
  end



end

