#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '4h', :first_in => 2 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :timeout => 120000)
  results = client.execute("
  USE iMIS

  DECLARE @year DATE = '2013'

    SELECT '2013' 'Year', SUM(AMOUNT) 'Amount', COUNT(DISTINCT(ID)) 'Donors'
    FROM Activity
    WHERE
      ACTIVITY_TYPE = 'GIFT' AND
      TRANSACTION_DATE >= @year AND
      TRANSACTION_DATE <= GETDATE() --Seems stupid but this prevents time travellers from distorting the figures
  UNION
    SELECT '2012' 'Year', SUM(AMOUNT) 'Amount', COUNT(DISTINCT(ID)) 'Donors'
    FROM Activity
    WHERE
      ACTIVITY_TYPE = 'GIFT' AND
      TRANSACTION_DATE >= DATEADD(YEAR,-1,@year) AND
      TRANSACTION_DATE <= DATEADD(YEAR,-1,GETDATE())")
  amount = Hash.new

  results.each do |row|
    amount[row['Year']] = row['Amount'].round
  end

  send_event('iMIS_total_donation_year-to-date', { current: amount['2013'], last: amount['2012'] })
end
