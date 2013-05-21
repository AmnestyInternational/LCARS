#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '19h', :first_in => 360 do |job|

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
USE iMIS
SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, TRANSACTION_DATE), 0) 'Month', COUNT(SEQN) 'Count'
FROM Activity
WHERE
  UF_2 IN ('COMM_1800','COMM_TIGERTEL') AND
  TRANSACTION_DATE >= DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, -9, GETDATE())), 0) AND
  TRANSACTION_DATE <= GETDATE()
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, TRANSACTION_DATE), 0)
ORDER BY Month ASC")

  points = Array.new
  last_x = 0

  result.each do | row |
    puts row['Count']
    points << { x: last_x, y: row['Count'] }
    puts points.inspect
    last_x += 1
    send_event('iMIS_calls_taken_monthly_graph', points: points)
    puts points.inspect
  end

end
