#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '4h', :first_in => 190 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :timeout => 120000)
  results = client.execute("
USE iMIS

  SELECT 'Current' 'Month', COUNT(SEQN) 'Count'
  FROM Activity
  WHERE
    UF_2 IN ('COMM_1800','COMM_TIGERTEL') AND
    TRANSACTION_DATE >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) AND
    TRANSACTION_DATE <= GETDATE()
  GROUP BY MONTH(TRANSACTION_DATE)
UNION
  SELECT 'Last' 'Month', COUNT(SEQN) 'Call count'
  FROM Activity
  WHERE
    UF_2 IN ('COMM_1800','COMM_TIGERTEL') AND
    TRANSACTION_DATE >= DATEADD(MONTH, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) AND
    TRANSACTION_DATE <= DATEADD(MONTH, -1, GETDATE())
  GROUP BY MONTH(TRANSACTION_DATE)")
  amount = Hash.new

  results.each do |row|
    amount[row['Month']] = row['Count'].round
  end

  send_event('iMIS_calls_taken_month-to-date', { current: amount['Current'], last: amount['Last'] })
end
