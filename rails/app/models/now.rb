module Now

  # change this as needed for testing the app at different times of the day
  # TODO. if early AM, use an hour over 24; e.g. 25:00:00
  def self.time
    value =  Time.now.strftime "%H:%M:%S"
    # This algorithm is an imperfect compromise, because some start_times of the
    # next day's trips are as early as 3 am, and some end_times of the trip from
    # the prev day are after three
    if Time.now.hour < 4
      hour, min, sec = value.split(":")
      hour = hour.to_i + 24
      "#{hour}:#{min}:#{sec}"
    else
      value
    end
  end

  # TODO in early AM hours, use the previous day
  def self.date
    if Time.now.hour < 4
      Date.yesterday.to_s
    else
      Date.today.to_s
    end
  end
end
