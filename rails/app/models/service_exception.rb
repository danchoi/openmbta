class ServiceException < ActiveRecord::Base
  belongs_to :service

  def self.populate
    Generator.generate('calendar_dates.txt') do |row|
      service = Service.find_by_mbta_id row[0]
      next false unless service
      ServiceException.create :service => service,
        :date => Date.new(*ParseDate::parsedate(row[1])[0,3]),
        :exception_type => row[2]
    end
  end

end
