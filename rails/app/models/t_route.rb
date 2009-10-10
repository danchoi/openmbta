class TRoute 

  def self.all
    Route.all :conditions => ["route_type in (0, 1)"]
  end

  def trips
    @routes.map {|r| r.trips}.flatten
  end

end
