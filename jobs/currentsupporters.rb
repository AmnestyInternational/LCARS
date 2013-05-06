#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('../suku_config/db_settings.yml'))

SCHEDULER.every '11m', :first_in => 0 do |job|
  client = TinyTds::Client.new(:username => yml['prod_settings']['username'], :password => yml['prod_settings']['password'], :host => yml['prod_settings']['host'])
  result = client.execute("SELECT COUNT(ID) AS 'CurrentSupporters' FROM externaldata.dbo.vAI_Definition_CurrentSupporter")
  current_supporters = result.first['CurrentSupporters']
  send_event('currentsupporters',   { value: current_supporters })
end
