require 'yaml'
require 'time_formatting'
class RealTime

  extend TimeFormatting

  def self.add_data(data, params)
    headsign = params[:headsign]
    route_short_name = params[:route_short_name]
    predictions_file = "#{Rails.root}/realtime/predictions/#{route_short_name}.yml"

    if File.exist?(predictions_file) && (File.mtime(predictions_file) > 30.minutes.ago)
      predictions = YAML::load(File.read(predictions_file))
      direction = predictions['directions'].detect {|d| d['headsign'] == headsign}

      if direction.nil?
        return data # abort
      end

      data[:stops].each do |stop_id, stop_data|
        stop_predictions = direction['stops'].
          detect {|s| 
            s['title'] == stop_data[:name]
          } 

        if stop_predictions.nil? || stop_predictions.empty?
          next
        end
        # replace next_arrivals
        data[:stops][stop_id][:next_arrivals] = stop_predictions['predictions'].
          select {|p| p['predicted_arrival'] >= Time.now}.
          map {|q| [format_time(q['predicted_arrival'].to_s.split(/\s/)[1][/(\d+:\d+)/,1]), q['vehicle']]}[0,3]

        unless data[:stops][stop_id][:next_arrivals].empty?
          data[:stops][stop_id][:next_arrivals] << ["(realtime)", 0]
        end
      end

      imminent_stop_ids = []
      if ! data[:stops][ data[:ordered_stop_ids].first ][:next_arrivals].empty?
        last_vehicle = data[:stops][ data[:ordered_stop_ids].first ][:next_arrivals][0][1]

        data[:ordered_stop_ids].each do |stop_id|
          stop_data = data[:stops][ stop_id ]
          next if stop_data[:next_arrivals].empty?
          vehicle = stop_data[:next_arrivals][0][1]
          if vehicle != last_vehicle
            imminent_stop_ids << stop_id.to_s
          end
          last_vehicle = vehicle
        end
      end
      data[:imminent_stop_ids] = imminent_stop_ids
      puts "NEW IMMINENT STOP IDS: #{imminent_stop_ids.inspect}"

      data['realtime'] = true
      puts data.inspect
      data
    else
      data
    end
  end
end

