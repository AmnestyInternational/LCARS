#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds' 

yml = YAML::load(File.open('../suku_config/db_settings.yml'))

SCHEDULER.every '1m' do
  lastqueryrun = []
  # Get SQL Errors
  client = TinyTds::Client.new(:username => yml['prod_settings']['username'], :password => yml['prod_settings']['password'], :host => yml['prod_settings']['host'])
  result = client.execute("
    USE externaldata
    SELECT
     (SELECT MAX(updated) 'latest' FROM fb_link_count) 'fb_link_count',
     (SELECT MAX(updated_time) 'latest' FROM fb_page_post) 'fb_page_post',
     (SELECT MAX(updated) 'latest' FROM fb_page_post_stat) 'fb_page_post_stat'")
  
  counts = result.first

  lastqueryrun << {:label => 'fb_link_count', :value => counts['fb_link_count']}
  lastqueryrun << {:label => 'fb_page_post', :value => counts['fb_page_post']}
  lastqueryrun << {:label => 'fb_page_post_stat', :value => counts['fb_page_post_stat']}

  send_event('latestqueryrun', { items: lastqueryrun })

end

# For a prettier formatting output
=begin
    USE test
    SELECT
     (SELECT CONVERT(VARCHAR, MAX(updated), 8) 'latest' FROM fb_link_count) 'fb_link_count',
     (SELECT CONVERT(VARCHAR, MAX(updated_time), 8) 'latest' FROM fb_page_post) 'fb_page_post',
     (SELECT CONVERT(VARCHAR, MAX(updated), 8) 'latest' FROM fb_page_post_stat) 'fb_page_post_stat'
=end
