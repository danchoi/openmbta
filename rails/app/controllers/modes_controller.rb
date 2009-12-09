class ModesController < ApplicationController
  layout false

  def index
    @modes = %W[ bus commuter_rail subway boat ]
  end

end
