#!/usr/bin/env ruby

# takes routeConfig.yml and fetches predictions for that route, in all
# directions
# Outputs an xml file of predictions for the route

require 'yaml'

info = YAML::load STDIN.read

url = "http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=mbta"

# &stops=39|null|6570
route_tag = info['route_tag']
params = info['stops'].keys.map {|stop_tag| "stops=#{route_tag}|null|#{stop_tag}"}.join("&")

command = "#{url}&#{params}"
puts `curl -s '#{command}'`

