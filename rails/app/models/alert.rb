require 'open-uri'
require 'hpricot'

class Alert < ActiveRecord::Base
  validates_uniqueness_of :guid
  validates_presence_of :title

  FEED_URL = "http://talerts.com/rssfeed/alertsrss.aspx"

  def self.fetch_and_parse
    parse(fetch)
  end

  def self.update_rss
    fetch_and_parse.each do |item_hash|
      self.create(item_hash)
    end
  end

  def self.fetch
    open(FEED_URL).read
  end

  def self.parse(xml)
    doc = Hpricot(xml)
    items = doc.search("//item").map do |item|
      %w{title description link guid pubDate}.inject({}) do |memo, x|
        memo[(x == 'pubDate' ? :pub_date : x.to_sym)] = item.at("/#{x}").inner_text
        memo
      end
    end
  end

  def pub_date
    read_attribute(:pub_date).in_time_zone.strftime('%x %I:%M %p')
  end

  def title
    read_attribute(:title).gsub(/\s{2,}/, ' ')
  end

  def to_json(options={})
    super(options.merge(:only => [:title, :pub_date, :guid]))
  end
end
