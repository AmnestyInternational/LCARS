#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '10m', :first_in => 115 do |job|
  inputcounts = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    USE iMIS
    SELECT UF_3 'Name', COUNT('SEQN') 'Count'
    FROM activity
    WHERE
      ACTIVITY_TYPE = 'NOTES' AND
      UF_3 IN ('Aengus Bridgman','Jennifer Auten','Will Bryant','David Griffiths','Member Services Volunteer') AND
      SEQN >= (
        SELECT TOP 1 SEQN
        FROM Activity
        WHERE
         TRANSACTION_DATE >= DATEADD(DAY, -3, GETDATE()) AND
         TRANSACTION_DATE <= GETDATE()
        ORDER BY SEQN) -- This is the earliest Transaction Date
    GROUP BY UF_3
    ORDER BY COUNT('SEQN') DESC
    ")

  result.each do |row|
    inputcounts << {:label=>row['Name'], :value=>row['Count']}
  end

  send_event('iMIS_note_input_counts', { items: inputcounts })

end

SCHEDULER.every '5m', :first_in => 71 do |job|
  msvinputcounts = []

  result = client.execute("
    SELECT UF_2 'Note_type', COUNT(SEQN) 'Count'
    FROM Activity
    WHERE
      UF_3 = 'Member Services Volunteer' AND
      SEQN >= (
        SELECT MIN(SEQN)
        FROM Activity
        WHERE
         TRANSACTION_DATE >= CAST(GETDATE() AS DATE) AND
         TRANSACTION_DATE <= GETDATE())
    GROUP BY UF_2
    ")

  result.each do |row|
    msvinputcounts << {:label=>row['Note_type'], :value=>row['Count']}
  end

  send_event('iMIS_member_services_volunteer_counts', { items: msvinputcounts })

end
