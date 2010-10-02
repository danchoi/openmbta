require 'csv'
require 'yaml'

class SubwayRealTime
  if defined? RAILS_ENV
    require 'time_formatting'
    extend TimeFormatting
  end

  def self.predictions_file(route_short_name, headsign)
    filename = case route_short_name
               when "Red Line"
                 "red.yml"
               when "Blue Line"
                 "blue.yml"
               when "Orange Line"
                 "orange.yml"
               end
    "#{Rails.root}/realtime/predictions/#{filename}"
  end

  def self.available?(route_short_name, headsign)
    if RAILS_ENV == 'development'
      return true
    end
    file = predictions_file(route_short_name, headsign)
    File.exist?(file) && (File.mtime(file) > 25.minutes.ago)
  end

  def self.add_data(data, params)
    puts "DATA FOR PARAMS: #{params}"
    headsign = params[:headsign]
    route_short_name = params[:route_short_name]
    first_stop = params[:first_stop]

    if !available?(route_short_name, headsign)
      return data
    end
      
    stopsdict = YAML::load(File.read(predictions_file(route_short_name, headsign)))
    puts "=" * 80

    #puts stopsdict
    if data[:stops].nil?
      return data
    end
    data[:stops].each do |stop_id, stop_data|
      stop_predictions = stopsdict[stop_data[:parent_stop_mbta_id]]
      if stop_predictions.nil? 
        data[:stops][stop_id][:next_arrivals] = [["real time data missing", nil]]
        next
      end

      if headsign =~ /Mattapan/ || first_stop =~ /^Mattapan/ 
        return data
      end

      # TODO select for direction
      direction_code = case headsign
                       when /Braintree/
                         'S'
                       when /Alewife/
                         'N'
                       when /Bowdoin/
                         'W'
                       when /Wonderland/
                         'E'
                       when /Forest Hills/
                         'S'
                       when /Oak Grove/
                         'N'
                       end
      stop_predictions = stop_predictions.select {|p| p[:direction] == direction_code}

      if stop_predictions.empty?
        data[:stops][stop_id][:next_arrivals] = [["real time data missing", nil]]
        next
      end

      # replace next_arrivals
      fmt = "%m/%d/%Y %I:%M:%S %p %Z"
      data[:stops][stop_id][:next_arrivals] = stop_predictions.
        select {|q|
          datetime = DateTime.strptime(q[:time] + " -0400", fmt)  # HACK. CHANGME later
          puts "*" * 80
          puts " #{q[:name]} #{datetime} > #{Time.now.to_datetime} #{ datetime > Time.now.to_datetime }"
          datetime > Time.now.to_datetime
        }.map {|q| 
          datetime = DateTime.parse(q[:time])
          time = "%.2d:%.2d:%.2d" % [datetime.hour, datetime.min,datetime.sec] 
          [format_time(time), q[:trip_id]]
        }[0,3]

      if data[:stops][stop_id][:next_arrivals].empty?
        data[:stops][stop_id][:next_arrivals] << ["real time data missing", nil]
      else
        data[:stops][stop_id][:next_arrivals] << ["(realtime)", 0]
      end
    end
    if ! data[:stops][ data[:ordered_stop_ids].first ][:next_arrivals].empty?
      trip_ids = {}
      #last_trip_id = data[:stops][ data[:ordered_stop_ids].first ][:next_arrivals][0][1]

      data[:ordered_stop_ids].each do |stop_id|
        stop_data = data[:stops][ stop_id ]
        next if stop_data[:next_arrivals].empty?
        prediction = stop_data[:next_arrivals].first
        time, trip_id = *prediction
        next if time =~ /realtime/
        trip_ids[trip_id] ||= []
        trip_ids[trip_id] << [time, trip_id, stop_id]
      end

      imminent_stop_ids = []
      trip_ids.each do |k,v|
        next if k == nil
        puts v.first.inspect
        imminent_stop_ids << v.first[2].to_s
      end

      data['realtime'] = true
      data[:imminent_stop_ids] = imminent_stop_ids
      puts "NEW IMMINENT STOP IDS: #{imminent_stop_ids.inspect}"
    end

    puts data.inspect
    data
  end


end

if __FILE__ == $0
  lines = STDIN.readlines
  res = SubwayRealTime.compile(lines)
  puts res.to_yaml
end
