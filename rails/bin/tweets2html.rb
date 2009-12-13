#!/usr/bin/env ruby

require 'rexml/document'


xml_string = STDIN.read
doc = REXML::Document.new(xml_string)

entries = []
doc.elements.each("//entry") do |entry|
  entries << { :published => DateTime.parse(entry.elements["published"].text),
    :image => entry.elements["link[@rel='image']"].attributes["href"],
    :name => entry.elements["author/name"].text,
    :uri => entry.elements["author/uri"].text,
    :content => entry.elements["content"].text
  }
end


