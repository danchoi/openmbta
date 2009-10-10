class Stop < ActiveRecord::Base
  has_many :stoppings
  has_many :trips, :through => :stoppings
  validates_uniqueness_of :mbta_id

  # returns stoppings representing the upcoming arrivals at this stop
  def arrivals(options)
    route_short_name = options[:route_short_name]
    headsign = options[:headsign]
    date = options[:date] || Date.today.to_s
    service_ids = Service.active_on(date).map(&:id)
    route_ids = Route.all(:conditions => {:short_name => options[:route_short_name]}).map(&:id)

    now = Time.now.strftime "%H:%M:%S"
    stoppings = Stopping.all(
      :joins => "inner join trips on trips.id = stoppings.trip_id",
      :conditions => ["trips.route_id in (?) and trips.service_id in (?) and trips.headsign = ? " +
        "and trips.end_time > '#{now}'", route_ids, service_ids, headsign],
      :order => "stoppings.arrival_time asc")
  end


  def self.populate
    Generator.generate('stops.txt') do |row|
      Stop.create :mbta_id => row[0],
        :name => row[2],
        :lat => row[4],
        :lng => row[5]
    end
  end
end
