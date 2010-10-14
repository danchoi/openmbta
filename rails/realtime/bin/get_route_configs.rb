#!/usr/bin/env ruby
require 'nokogiri'
require 'yaml'

route_tags = %W{ 1 4 5 7 8 9 10 11 14 15 16 17 18 19 21 22 23 24 26 27 28 29 30 31 32 33 34 34E 35 36 37 38 39 40 41 42 43 44 45 47 48 50 51 52 55 57 59 60 62 64 65 66 67 68 69 70 70A 71 72 73 74 75 76 77 78 79 80 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 99 100 101 104 105 106 108 109 110 111 111C 112 114 116 117 119 120 121 131 132 134 136 137 170 171 191 192 193 194 201 202 210 211 212 214 215 216 217 220 221 222 225 225C 230 236 238 240 245 274 275 276 277 325 326 350 351 352 354 355 411 424 424W 426 426W 428 429 430 430G 431 434 435 436 439 441 441W 442 442W 448 449 450 450W 451 455 455W 456 459 465 468 500 501 502 503 504 505 553 554 555 556 558 701 708 741 742 746 747 748 749 751 9109 9111 9501 9507 9701 9702 9703 }


def yamlize(route_config_xml)
  stops = {}
  doc = route_config_xml
  doc.split("\n").each do |line|
    if line =~ /^<stop/
      tag = line[/tag="([^"]+)"/, 1]
      title = line[/title="([^"]+)"/, 1]
      stops[tag.to_s] = title
    end
  end
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
  out.to_yaml
end


route_tags.each do |route_tag|
  xml = %x{curl -s "http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=mbta&r=#{route_tag}" }
  puts "saving route_configs/#{route_tag}.yml" 
  File.open("route_configs/#{route_tag}.yml", 'w') {|f| f.puts yamlize(xml)}
  sleep 10
end


