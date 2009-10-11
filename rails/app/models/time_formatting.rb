module TimeFormatting

  def format_time(time)
    # "%H:%M:%S" -> 12 hour clock with am or pm
    hour, min = time.split(":")[0,2]
    hour = hour.to_i
    suffix = 'am'
    if hour > 24
      hour = hour - 24
      suffix = 'am'
    elsif hour == 24
      hour = 12
      suffix = 'am'
    elsif hour > 12
      hour = hour - 12
      suffix = 'pm'
    end
    "#{hour}:#{min}#{suffix}"
  end


end
