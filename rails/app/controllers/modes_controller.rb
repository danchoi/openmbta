class ModesController < ApplicationController
  layout 'mobile'

  def index
    @modes = %W[ bus commuter_rail subway boat ]
  end

end
