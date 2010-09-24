module TimeFormatting

  def format_time(time)
    # "%H:%M:%S" -> 12 hour clock with am or pm
    hour, min = time.split(":")[0,2]
    hour = hour.to_i
    suffix = 'a'
    if hour > 24
      hour = hour - 24
    elsif hour == 12
      suffix = 'p'
    elsif hour == 24
      hour = 12
      suffix = 'a'
    elsif hour > 12
      hour = hour - 12
      suffix = 'p'
    elsif hour == 0
      suffix = 'a'
      hour = 12 # midnight
    end
    "#{hour}:#{min}#{suffix}"
  end


end
