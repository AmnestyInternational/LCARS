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
      TRANSACTION_DATE > DATEADD(DAY, -3, GETDATE()) AND
      UF_3 != '' AND
      UF_3 IN ('Aengus Bridgman','Jennifer Auten','Will Bryant','David Griffiths')
    GROUP BY UF_3
    ORDER BY COUNT('SEQN') DESC
    ")

  result.each do |row|
    inputcounts << {:label=>row['Name'], :value=>row['Count']}
  end

  send_event('iMIS_note_input_counts', { items: inputcounts })

end
