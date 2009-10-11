module Now

  # change this as needed for testing the app at different times of the day
  def self.time
    Time.now.strftime "%H:%M:%S"
  end

  def self.date
    Date.today.to_s
  end
end
