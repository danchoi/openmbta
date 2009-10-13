class Now

  def initialize(reference_time = Time.now)
    @reference_time = reference_time
  end

  # change this as needed for testing the app at different times of the day
  # TODO. if early AM, use an hour over 24; e.g. 25:00:00
  def time
    value = @reference_time.strftime "%H:%M:%S"
    # This algorithm is an imperfect compromise, because some start_times of the
    # next day's trips are as early as 3 am, and some end_times of the trip from
    # the prev day are after three
    if @reference_time.hour < 4
      hour, min, sec = value.split(":")
      hour = hour.to_i + 24
      "#{hour}:#{min}:#{sec}"
    else
      value
    end
  end

  # TODO in early AM hours, use the previous day
  def date
    if @reference_time.hour < 4
      Date.yesterday.to_s
    else
      Date.today.to_s
    end
  end
end
