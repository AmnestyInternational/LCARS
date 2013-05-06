#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('../suku_config/db_settings.yml'))

SCHEDULER.every '4h', :first_in => 0 do |job|
  client = TinyTds::Client.new(:username => yml['prod_settings']['username'], :password => yml['prod_settings']['password'], :host => yml['prod_settings']['host'], :timeout => 120000)
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

  send_event('totaldonationsyeartodate', { current: amount['2013'], last: amount['2012'] })
end
