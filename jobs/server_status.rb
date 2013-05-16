#!/usr/bin/env ruby
require 'yaml'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '1m', :first_in => 2 do |job|
  serverstats = []
  loadavg = []
  # Get SQL Errors
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("SELECT @@total_errors AS 'TotalErrors'")
  totalsqlerrors = result.first['TotalErrors']

  uptime = %x('uptime')

  loadavg[1] = uptime[-17..-14]
  loadavg[5] = uptime[-11..-8]
  loadavg[15] = uptime[-5..-2]

  serverstats << {:label => '1 min load', :value => loadavg[1]}
  serverstats << {:label => '5 min load', :value => loadavg[5]}
  serverstats << {:label => '15 min load', :value => loadavg[15]}
  serverstats << {:label => 'SQL Errors', :value => totalsqlerrors}

  send_event('server_status', { items: serverstats })

end
