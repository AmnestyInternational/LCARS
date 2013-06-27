#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
require 'date'

def seconds_since_midnight
  (Time.now.hour * 3600) + (Time.now.min * 60) + (Time.now.sec)
end

starttime = seconds_since_midnight - (72 * 60 * 10)
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

points = []
(1..72).each do | i |
  points << { x: (i * 60 * 10) + starttime, y: 0 }
end

SCHEDULER.every '10m', :first_in => 39 do |job|
  points.shift

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
    USE externaldata
    SELECT TOP 1 share_count
    FROM fb_page_post_stat
    WHERE post_id = (SELECT TOP 1 post_id FROM fb_page_post WHERE type IN ('247','80') ORDER BY created_time DESC)
    ORDER BY created DESC")

  points << { x: seconds_since_midnight, y: result.first['share_count'] }

  send_event('Facebook_AIC_page_post_share_growth', points: points)

end
