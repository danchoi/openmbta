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
  def self.routes(*transport_types) 
    logger.debug("Transport type: #{transport_types.inspect}")
    date = Date.today.to_s
    service_ids = Service.active_on(date).map(&:id)

    case transport_types 
    when [3] # bus
      ActiveRecord::Base.connection.select_all("select case when routes.short_name = ' ' then 'Other' else routes.short_name end route_short_name, trips.headsign from routes inner join trips on trips.route_id = routes.id where routes.route_type in (#{transport_types.join(',')}) and trips.service_id in (#{service_ids.join(',')}) group by routes.short_name, trips.headsign").
        group_by {|r| r["route_short_name"]}.
        map {|short_name, values| {:route_short_name => short_name, 
            :headsigns => values.map {|x| 
              x["headsign"] 
            } 
          } 
        }.
        sort_by {|x| x[:route_short_name].to_i == 0 ? 10000 : x[:route_short_name].to_i }
    when [4] # boat: has no headsigns, so construct one from mbta id
    when [0,1] # subway
      results = [{
        :route_short_name => "Commuter Rail Lines",
        :headsigns => ActiveRecord::Base.connection.select_all("select mbta_id from routes where route_type = 2 order by mbta_id asc").map {|x| x['mbta_id'].sub(/^CR-/, '')}
      }]

    else # commuter rail
      results = [{
        :route_short_name => "Commuter Rail Lines",
        :headsigns => ActiveRecord::Base.connection.select_all("select mbta_id from routes where route_type = 2 order by mbta_id asc").map {|x| x['mbta_id'].sub(/^CR-/, '')}
      }]
    end
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
