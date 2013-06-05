#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '6h', :first_in => 75 do |job|
  newcyberactivistscount = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
    USE externaldata
    -- New cyber activists by day
    SELECT supporter_create_date, COUNT(supporter_id) 'Count'
    FROM ENsupporters
    WHERE
      supporter_create_date >= DATEADD(DAY, -8, GETDATE()) AND
      supporter_id IN (
        SELECT supporter_id
        FROM ENsupportersActivities
        WHERE
          status = 'P' AND
          type IN ('DC','ET'))
    GROUP BY supporter_create_date
    ORDER BY supporter_create_date DESC")

  result.each do |row|
    newcyberactivistscount << {:label=>row['supporter_create_date'], :value=>row['Count']}
  end

  send_event('EN_new_cyber_activists_count', { items: newcyberactivistscount })

end


SCHEDULER.every '6h', :first_in => 93 do |job|
  newonlinedonorscount = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
    USE externaldata
    -- New online donors by day
    SELECT supporter_create_date, COUNT(supporter_id) 'Count'
    FROM ENsupporters
    WHERE
      supporter_create_date >= DATEADD(DAY, -8, GETDATE()) AND
      supporter_id IN (
        SELECT supporter_id
        FROM ENsupportersActivities
        WHERE type = 'CREDIT/DEBIT_SIN')
    GROUP BY supporter_create_date
    ORDER BY supporter_create_date DESC")

  result.each do |row|
    newonlinedonorscount << {:label=>row['supporter_create_date'], :value=>row['Count']}
  end

  send_event('EN_new_online_donors_count', { items: newonlinedonorscount })

end


SCHEDULER.every '6h', :first_in => 43 do |job|
  topcyberactions = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
    USE externaldata
    -- Top 7 cyber actions in past 7 days
    SELECT TOP 7 LEFT(id, 15) 'Action', COUNT(supporter_id) 'Count'
    FROM ENsupportersActivities
    WHERE
      type IN ('ET','DC') AND
      datetime > DATEADD(DAY, -7, GETDATE())
    GROUP BY id
    ORDER BY COUNT(supporter_id) DESC")

  result.each do |row|
    topcyberactions << {:label=>row['Action'], :value=>row['Count']}
  end

  send_event('EN_top_cyber_actions_count', { items: topcyberactions })

end





