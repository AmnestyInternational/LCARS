#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
require 'date'

def seconds_since_midnight
  (Time.now.hour * 3600) + (Time.now.min * 60) + (Time.now.sec)
end

starttime = seconds_since_midnight - (36 * 60 * 10)
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

points = []
(1..36).each do | i |
  points << { x: (i * 60 * 10) + starttime, y: 0 }
end

SCHEDULER.every '10m', :first_in => 37 do |job|
  points.shift

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
    USE externaldata
    SELECT TOP 1 likes_count
    FROM fb_page_post_stat
    WHERE post_id = (SELECT TOP 1 post_id FROM fb_page_post WHERE type IN ('247','80') ORDER BY created_time DESC)
    ORDER BY updated DESC")

  points << { x: seconds_since_midnight, y: result.first['likes_count'] }

  send_event('Facebook_AIC_page_post_like_growth', points: points)

end
