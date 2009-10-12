class Route < ActiveRecord::Base
  has_many :trips
  validates_uniqueness_of :mbta_id

  named_scope :with_short_names, :conditions => "short_name is not null"

  named_scope :subgrouped_by_headsign, :select => "routes.*, trips.headsign as headsign",
    :joins => :trips,
    :group => "routes.id, trips.headsign",
    :order => "convert(routes.short_name, unsigned), trips.headsign"

  named_scope :bus, :conditions => "routes.route_type in (3)"
  named_scope :commuter_rail, :conditions => "routes.route_type in (2)"
  named_scope :subway, :conditions => "routes.route_type in (0,1)"
  named_scope :boat, :conditions => "routes.route_type in (4)"

  # date is a string YYYYMMDD 
  def self.routes(transport_type) 
    date = Date.today.to_s
    service_ids = Service.active_on(date).map(&:id)
    transport_type.to_s.camelize.constantize.routes(service_ids)
  end

  def self.populate
    Generator.generate('routes.txt') do |row|
      Route.create :mbta_id => row[0],
        :short_name => row[2],
        :long_name => row[2],
        :route_type => row[5]
    end
  end

  def self.cache_short_name_on_trips
    self.with_short_names.each do |route|
      route.cache_short_name_on_trips
    end
  end

  def cache_short_name_on_trips 
    self.trips.each do |trip|
      trip.update_attribute :route_short_name, self.short_name
      print '.'
    end
  end

  TransportType = {
    0 => 'subway',
    1 => 'streetcar',
    2 => 'commuter rail',
    3 => 'bus',
    4 => 'ferry'
  }

  def transport_type
    TransportType[route_type]
  end

end
