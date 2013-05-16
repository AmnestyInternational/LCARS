#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '11m', :first_in => 2 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("SELECT COUNT(ID) AS 'CurrentSupporters' FROM externaldata.dbo.vAI_Definition_CurrentSupporter")
  current_supporters = result.first['CurrentSupporters']
  send_event('iMIS_current_supporters',   { value: current_supporters })
end
