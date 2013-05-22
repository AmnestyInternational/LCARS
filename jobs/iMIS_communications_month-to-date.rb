#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '15m', :first_in => 35 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :timeout => 120000)
  results = client.execute("
    USE iMIS

    DECLARE @firstthismonth DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    DECLARE @firstlastmonth DATE = DATEADD(MONTH, -1, @firstthismonth)
    DECLARE @nowthismonth DATE = GETDATE()
    DECLARE @notlastmonth DATE = DATEADD(MONTH, -1, @nowthismonth)

    SELECT RIGHT(UF_2, LEN(UF_2) - 5) 'Type', COUNT(SEQN) 'Count'
    FROM Activity
    WHERE
      UF_2 LIKE 'COMM_%' AND
      TRANSACTION_DATE >= @firstthismonth AND
      TRANSACTION_DATE <= @nowthismonth
    GROUP BY RIGHT(UF_2, LEN(UF_2) - 5)
    ")
  currentmonth = Hash.new

  results.each do | row |
    currentmonth[row['Type']] = row['Count']
  end

  results = client.execute("
    USE iMIS

    DECLARE @firstthismonth DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    DECLARE @firstlastmonth DATE = DATEADD(MONTH, -1, @firstthismonth)
    DECLARE @nowthismonth DATE = GETDATE()
    DECLARE @notlastmonth DATE = DATEADD(MONTH, -1, @nowthismonth)

    SELECT RIGHT(UF_2, LEN(UF_2) - 5) 'Type', COUNT(SEQN) 'Count'
    FROM Activity
    WHERE
      UF_2 LIKE 'COMM_%' AND
      TRANSACTION_DATE >= @firstlastmonth AND
      TRANSACTION_DATE <= @notlastmonth
    GROUP BY RIGHT(UF_2, LEN(UF_2) - 5)
    ")
  lastmonth = Hash.new

  results.each do | row |
    lastmonth[row['Type']] = row['Count']
  end
  
  puts currentmonth.inspect
  puts lastmonth.inspect
  
  send_event('iMIS_calls_month-to-date', { current: currentmonth['1800'] + currentmonth['TIGERTEL'], last: lastmonth['1800'] + lastmonth['TIGERTEL'] })  
  send_event('iMIS_phone_month-to-date', { current: currentmonth['PHONE'], last: lastmonth['PHONE'] })  
  send_event('iMIS_mail_month-to-date', { current: currentmonth['EMAIL'], last: lastmonth['EMAIL'] })  
  send_event('iMIS_coupon_month-to-date', { current: currentmonth['COUPON'], last: lastmonth['COUPON'] })  
  send_event('iMIS_in_person_month-to-date', { current: currentmonth['IN_PERSON'], last: lastmonth['IN_PERSON'] })  
  send_event('iMIS_web_month-to-date', { current: currentmonth['WEB'] + currentmonth['WEB_CONTACT_FORM'], last: lastmonth['WEB'] + lastmonth['WEB_CONTACT_FORM'] })

end



