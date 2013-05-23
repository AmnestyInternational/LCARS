#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds' 

yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '5m', :first_in => 37 do |job|
  lastqueryrun = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
    USE externaldata
    SELECT
     (SELECT MAX(updated) FROM fb_link_count) 'fb_link_count',
     (SELECT MAX(updated_time) FROM fb_page_post) 'fb_page_post',
     (SELECT MAX(updated) FROM fb_page_post_stat) 'fb_page_post_stat',
     (SELECT MAX(imported) FROM tweets) 'tweets',
     (SELECT MAX(max_id) FROM TweetsRefreshUrl) 'max_id',
     (SELECT MAX(imported) FROM ENsupportersActivities) 'EN_activities'")
  
  counts = result.first

  lastqueryrun << {:label => 'fb_link_count', :value => counts['fb_link_count']}
  lastqueryrun << {:label => 'fb_page_post', :value => counts['fb_page_post']}
  lastqueryrun << {:label => 'fb_page_post_stat', :value => counts['fb_page_post_stat']}
  lastqueryrun << {:label => 'tweets', :value => counts['tweets']}
  lastqueryrun << {:label => 'max tweet id', :value => counts['max_id']}
  lastqueryrun << {:label => 'EN Activities', :value => counts['EN_activities']}

  send_event('DB_latest_query_runtime', { items: lastqueryrun })

end
