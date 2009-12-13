require 'rexml/document'
class TweetsController < ApplicationController
  layout 'mobile'
  def index
    cmd  = "curl -s http://search.twitter.com/search.atom?q=%23mbta"
    logger.debug cmd
    xml_string = `#{cmd}`

    doc = REXML::Document.new(xml_string)

    @entries = []
    doc.elements.each("//entry") do |entry|
      @entries << { :published => DateTime.parse(entry.elements["published"].text),
        :image => entry.elements["link[@rel='image']"].attributes["href"],
        :name => entry.elements["author/name"].text,
        :uri => entry.elements["author/uri"].text,
        :content => entry.elements["content"].text
      }
    end

  end

end
