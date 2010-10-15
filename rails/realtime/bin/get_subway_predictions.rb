`curl -s "http://developer.mbta.com/Data/Red.txt" > predictions/red.csv`
`curl -s "http://developer.mbta.com/Data/orange.txt" > predictions/orange.csv`
`curl -s "http://developer.mbta.com/Data/blue.txt" > predictions/blue.csv`
require 'csv'
require 'yaml'

def compile(lines, line)
  lines.map {|x| translate(CSV.parse_line(x), line)}.group_by {|x| x[:stop_id]}
end

def translate(line_data, line)
  stop_key = line_data[2].strip
  data = stop_keys[stop_key]
  if data.nil?
    puts "#{line_data.inspect} has no matching stop"
    return
  end
  res = data.merge :time => line_data[4].strip, :direction => stop_key[-1,1], :trip_id => line_data[1].strip
end

def stop_keys
  return @stop_keys if @stop_keys
  @stop_keys  = {}
  File.open("route_configs/RealTimeHeavyRailKeys.csv").readlines[1..-1].map {|line| CSV.parse_line(line)}.
    each do |line| 
      key = line[1].strip
      stop_id = line[9]
      @stop_keys[key] = {:stop_id => stop_id, :name => line[11]}
    end
  @stop_keys
end

11.times do 
  %W{ predictions/red predictions/blue predictions/orange}.each do |x|
    line = x.split('/').last
    res = compile(File.readlines("#{x}.csv"), line)
    File.open("#{x}.yml", 'w') {|f| f.puts res.to_yaml}
  end
  sleep 5
end
