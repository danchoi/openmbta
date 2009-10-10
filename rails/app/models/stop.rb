class Stop < ActiveRecord::Base
  has_many :stoppings
  has_many :trips, :through => :stoppings
  validates_uniqueness_of :mbta_id

  def self.populate
    Generator.generate('stops.txt') do |row|
      Stop.create :mbta_id => row[0],
        :name => row[2],
        :lat => row[4],
        :lng => row[5]
    end
  end
end
