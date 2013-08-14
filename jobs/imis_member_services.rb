#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'

yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '60m', :first_in => 356 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :timeout => 120000)

  results = client.execute("
    USE iMIS

    SELECT
    (SELECT COUNT(ID)
    FROM Activity
    WHERE
      PRODUCT_CODE LIKE '%CC%UPDATER_PROGRAM%' AND
      TRANSACTION_DATE >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) AND
      TRANSACTION_DATE <= GETDATE()) 'CurrentMonth',
    (SELECT COUNT(ID)
    FROM Activity
    WHERE
      PRODUCT_CODE LIKE '%CC%UPDATER_PROGRAM%' AND
      TRANSACTION_DATE >= DATEADD(MONTH, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) AND
      TRANSACTION_DATE <= DATEADD(MONTH, -1, GETDATE())) 'LastMonth'
    ")
  counts = results.first
  
  send_event('iMIS_CC_Updater_month-to-date', { current: counts['CurrentMonth'], last: counts['LastMonth'] })

end
