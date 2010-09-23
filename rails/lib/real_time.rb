require 'yaml'
class RealTime
  def self.add_data(data, params)
    headsign = params[:headsign]
    route_short_name = params[:route_short_name]
    predictions_file = "#{Rails.root}/realtime/predictions/#{route_short_name}.yml"
    if File.exist? predictions_file
      predictions = YAML::load(File.read(predictions_file))
      direction = predictions['directions'].detect {|d| d['headsign'] == headsign}

      # what if directions nil?

      data[:stops].each do |stop_id, stop_data|
        stop_predictions = direction['stops'].detect {|s| s['name'] == stop_data['title']} 
        data[:stops][stop_id][:next_arrivals] = stop_predictions['predictions'].
          map {|p| [p['predicted_arrival'].to_s.split(/\s/)[1][/(\d+:\d+)/,1], 'realtime']}
      end
      data['realtime'] = true
      puts data.inspect
      data
    else
      data
    end
  end
end

