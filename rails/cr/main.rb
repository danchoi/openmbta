require 'open-uri'
require 'nokogiri'
require "rubygems"
gem "selenium-client", ">=1.2.16"
require "selenium/client"


def fetch(path)
  begin
    @browser = Selenium::Client::Driver.new :host => "localhost",
    :port => 4444,
    :browser => "*firefox",
    :url => "http://mbta.com/",
    :timeout_in_second => 60

    @browser.start_new_browser_session
    @browser.open path
    "<html>#{@browser.get_html_source}</html>"
  ensure
    @browser.close_current_browser_session
  end
end

def train_numbers(html)
  doc = Nokogiri::HTML.parse(html)
  numbers = doc.at("//table[@id='scheduletable']").
    children.search("tr[@class='number']/td").
    map {|x| x.inner_text.gsub(/(AM|PM)/, '').gsub(' ', '')}. 
    select {|x| x != ''}
  numbers
rescue 
  []
end

lines = []

File.open('main.txt').each do |line|
  url, title = line.split(" ")
  inbound = []
  outbound = []
  info = Hash.new({})
  ['W', 'S', 'U'].each do |day|
    ['I', 'O'].each do |direction|
      path = "#{url}&direction=#{direction}&timing=#{day}".sub(/\//, '')
      html = fetch path
      puts "#{title} #{day} #{direction}"
      numbers = train_numbers(html)
      info[direction][day] = numbers
      if direction == 'I'
        inbound << numbers
      else
        outbound << numbers
      end
      puts numbers.inspect
    end
  end
  lines << info.merge({:line => title, :inbound => inbound.flatten, :outbound => outbound.flatten})
  puts lines.inspect
end
require 'yaml'
File.open("lines.yml", 'w') {|f| f.puts lines.to_yaml}

__END__
http://mbta.com/schedules_and_maps/rail/lines/?route=FAIRMNT&direction=O&timing=W&RedisplayTime=Redisplay+Time

