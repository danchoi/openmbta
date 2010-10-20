require 'yaml'
require 'time_formatting'
class RealTime

  extend TimeFormatting

  def self.predictions_file(route_short_name, headsign)
    filename = case route_short_name 
               when 'CT1'
                 '701'
               when 'CT3'
                 '708'
               when 'CT2'
                 case headsign
                 when /Ruggles via Kendall/ # south
                   #'747'
                   'ct2'
                 when /Sullivan Station via Kendall/
                   'ct2' # also 748?
                 end
               when 'SL'
                 case headsign
                 when /SL1/
                   '741'
                 when /SL2/
                   '742'
                 when /SL4/
                   '751'
                 when /SL5/
                   '749'
                 when /Silver Line Way/

                 end
               else
                 route_short_name
               end

    "#{Rails.root}/realtime/predictions/#{filename}.yml"
  end

  def self.available?(route_short_name, headsign)
    file = predictions_file(route_short_name, headsign)
    if ( File.exist?(file) && (File.mtime(file) > 45.minutes.ago) )
      predictions = YAML::load(File.read(file))
      direction = predictions['directions'].detect {|d| d['headsign'] == headsign} rescue nil

      direction ? true : false
    else
      false
    end
  end

  def self.add_data(data, params)
    data = data.dup
    headsign = params[:headsign]
    route_short_name = params[:route_short_name]

    if available?(route_short_name, headsign)
      
      predictions = YAML::load(File.read(predictions_file(route_short_name, headsign)))

      direction = predictions['directions'].detect {|d| d['headsign'] == headsign} rescue nil

      # special case
      if route_short_name == '66'
        direction = predictions['directions'].select {|d| d['headsign'] == headsign}.last
      end

      if direction.nil? || data[:stops].nil? || direction['stops'].nil?
        return data # abort
      end

      if direction['stops'].all? {|x| x['predictions'].empty?}
        return data # abort
      end

      if data[:stops].nil?
        return data
      end

      data[:stops].each do |stop_id, stop_data|
        stop_predictions = direction['stops'].
          detect {|s| 
            #s['title'] == stop_data[:name]
            s['tag'].split("_").first == stop_data[:mbta_id].to_s || s['title'] == stop_data[:name]
          } 

        if RAILS_ENV == 'development'
          if stop_predictions.nil?
            puts "=" * 80
            puts stop_data.inspect
            puts "MTBA ID"
            puts stop_data[:mbta_id]
            puts "name"
            puts stop_data[:name]
            puts "TAGS"
            puts direction['stops'].map {|s| s['tag']}.inspect
            puts direction['stops'].map {|s| s['title']}.inspect
          end
        end
        if stop_predictions.nil? || stop_predictions['predictions'].empty?
          data[:stops][stop_id][:next_arrivals] = [["real time data missing", nil]]
          next
        end
        # replace next_arrivals
        data[:stops][stop_id][:next_arrivals] = stop_predictions['predictions'].
          select {|p| p['predicted_arrival'] >= Time.now}.
          map {|q| [format_time(q['predicted_arrival'].to_s.split(/\s/)[1][/(\d+:\d+)/,1]), q['vehicle']]}[0,3]

        if data[:stops][stop_id][:next_arrivals].empty?
          data[:stops][stop_id][:next_arrivals] << ["real time data missing", nil]
        else
          data[:stops][stop_id][:next_arrivals] << ["(realtime)", 0]
        end
      end

      if ! data[:stops][ data[:ordered_stop_ids].first ][:next_arrivals].empty?
        vehicles = {}
        #last_vehicle = data[:stops][ data[:ordered_stop_ids].first ][:next_arrivals][0][1]

        data[:ordered_stop_ids].each do |stop_id|
          stop_data = data[:stops][ stop_id ]
          next if stop_data[:next_arrivals].empty?
          prediction = stop_data[:next_arrivals].first
          time, vehicle = *prediction
          next if time =~ /realtime/
          vehicles[vehicle] ||= []
          vehicles[vehicle] << [time, vehicle, stop_id]
          
        end

        imminent_stop_ids = []
        vehicles.each do |k,v|
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
    else
      data
    end
  end
end

