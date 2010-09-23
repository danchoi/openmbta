#!/usr/bin/env ruby

# input is a routeconfig.xml for a route. output is a yaml file that should
# be piped into predictions_for_route.rb
#
#
require 'nokogiri'
require 'yaml'
stops = {}
doc = STDIN.read
doc.split("\n").each do |line|
  if line =~ /^<stop/
    tag = line[/tag="([^"]+)"/, 1]
    title = line[/title="([^"]+)"/, 1]
    stops[tag.to_s] = title
  end
end
#puts stops.inspect
doc = Nokogiri::XML.parse(doc)
directions = []
doc.xpath("//direction").each do |x|
  next unless x['useForUI'] == 'true'
  headsign = x['title']
  direction_name = x['name']

  direction_stops = x.children.search("stop").map do |stop|
    tag = stop['tag'].to_s
    {'tag' => tag, 'title' => stops[tag]}
  end
  directions << {'headsign' => headsign, 'direction_name' => direction_name, 'stops' => direction_stops} 
end
out = {'route_tag' => doc.xpath('//route')[0]['tag'], 
  'stops' => stops, 
  'directions' => directions}
puts out.to_yaml
