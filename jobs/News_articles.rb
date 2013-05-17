#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'yaml'
require 'tiny_tds'

yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '10m', :first_in => 30 do |job|

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  results = client.execute("
    SELECT TOP 8 title, (LEFT(description, 300) + '...') 'description'
    FROM Articles
    WHERE type = 'news'
    ORDER BY published DESC")

  newsarticles = Array.new

  if results
    results.each do | row |
      newsarticles << {name: row['title'], body: row['description']}
    end

    send_event('Amnesty_Canada_news_articles', comments: newsarticles)

    # RSS_feed_Google_News_Amnesty is redundent but I'll push to it incase there are some old dashboards using it
    send_event('RSS_feed_Google_News_Amnesty', comments: newsarticles)
  end
end
