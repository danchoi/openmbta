class Service < ActiveRecord::Base
  has_many :trips, :dependent => :destroy
  has_many :service_exceptions

  DAYS = %w{ sunday monday tuesday wednesday thursday friday saturday }

  named_scope :expired, :conditions => ["end_date < ?", Time.now]

  named_scope :presumably_active_on, lambda {|date|
    date = parse_date(date)
    {
      :conditions => ["services.start_date <= ? and services.end_date >= ? and services.#{DAYS[date.wday]} = 1 ", date, date]
    }
  }

  named_scope :removed_for, lambda {|date|
    date = parse_date(date)
    {
      :joins => "inner join service_exceptions on service_exceptions.service_id = services.id",
      :conditions => ["service_exceptions.date = ? and service_exceptions.exception_type = 2", date]
    }
  }

  named_scope :added_for, lambda {|date|
    date = parse_date(date)
    {
      :joins => "inner join service_exceptions on service_exceptions.service_id = services.id",
      :conditions => ["service_exceptions.date = ? and service_exceptions.exception_type = 1", date]
    }
  }

  def self.active_on(date)
    #puts "presumed: #{presumably_active_on(date).map(&:id).inspect}"
    #puts "removed: #{removed_for(date).map(&:id).inspect}"
    #puts "added: #{added_for(date).map(&:id).inspect}"
    (presumably_active_on(date) + added_for(date)).uniq - removed_for(date)
  end

  def self.active_today
    self.active_on(Now.date)
  end

  def self.ids_active_today
    self.active_on(Now.date).map(&:id)
  end


  def self.populate
    Generator.generate('calendar.txt') do |row|
      end_date = Date.new(*ParseDate::parsedate(row[9])[0,3])
      if end_date < Date.today
        next
      end
      service = Service.new :mbta_id => row[0]
      %w{monday tuesday wednesday thursday friday saturday sunday}.each_with_index do |day, index|
        service.send("#{day}=", row[index+1] == '1')
      end
      service.start_date = Date.new(*ParseDate::parsedate(row[8])[0,3])
      service.end_date = end_date
      service.save
    end
  end

  # YYYYMMDD
  def self.parse_date(date)
    if date.is_a?(String)
      Date.new(*ParseDate::parsedate(date)[0,3])
    else
      date
    end
  end
end
