#!/usr/bin/env ruby

# takes multistop predictions output xml in and generates a clean YAML version
# First arg should be path to routeConfig for route
require 'nokogiri'
require 'yaml'
route_config = YAML::load(File.read(ARGV.first))
doc = Nokogiri::XML.parse STDIN.read

route_config['directions'].each do |direction|

  direction['stops'].each do |stop|
    predictions = doc.xpath("//predictions[@stopTitle='#{stop['title']}']")
    stop['predictions'] = predictions.children.search("direction").
      detect {|d| d['title'] == direction['headsign']}.
      children.search('prediction').
      map {|prediction|
        { 'predicted_arrival' => Time.at((prediction['epochTime'].to_i/1000)),
          'vehicle' => prediction['vehicle']}}
  
  end
end
route_config.delete('stops')
puts route_config.to_yaml

exit

doc.xpath("//predictions").each do |predictions|
  predictions['routeTag']
  predictions['stopTitle']
  predictions['stopTag']

  predictions.children.search("direction") do |direction|
    direction['title']
    direction.children.search('prediction') do |prediction|
      prediction['seconds']
      prediction['minutes']
      prediction['epochTime']
      prediction['vehicle']
    end
  end
end

