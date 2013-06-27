#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '12h', :first_in => 47 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :timeout => 120000)
  results = client.execute("
    USE externaldata

    DECLARE @end DATE = GETDATE()
    DECLARE @start DATE = DATEADD(DAY, -7, @end)

    DECLARE @click FLOAT = (SELECT COUNT(SEQN) FROM ENsupportersActivities WHERE type = 'B' AND data2 = 'click' AND datetime >= @start AND datetime <= @end)
    DECLARE @formsub FLOAT = (SELECT COUNT(SEQN) FROM ENsupportersActivities WHERE type = 'B' AND data3 = 'formsub' AND datetime >= @start AND datetime <= @end)
    DECLARE @open FLOAT = (SELECT COUNT(SEQN) FROM ENsupportersActivities WHERE type = 'B' AND (data1 = 'open' OR (data1 IS NULL AND data2 = 'click')) AND datetime >= @start AND datetime <= @end)
    DECLARE @total FLOAT = (SELECT COUNT(SEQN) FROM ENsupportersActivities WHERE type = 'B' AND datetime >= @start AND datetime <= @end)

    SET @start = DATEADD(DAY, -7, @start)
    SET @end = DATEADD(DAY, -7, @end)

    DECLARE @lstclick FLOAT = (SELECT COUNT(SEQN) FROM ENsupportersActivities WHERE type = 'B' AND data2 = 'click' AND datetime >= @start AND datetime <= @end)
    DECLARE @lstformsub FLOAT = (SELECT COUNT(SEQN) FROM ENsupportersActivities WHERE type = 'B' AND data3 = 'formsub' AND datetime >= @start AND datetime <= @end)
    DECLARE @lstopen FLOAT = (SELECT COUNT(SEQN) FROM ENsupportersActivities WHERE type = 'B' AND (data1 = 'open' OR (data1 IS NULL AND data2 = 'click')) AND datetime >= @start AND datetime <= @end)
    DECLARE @lsttotal FLOAT = (SELECT COUNT(SEQN) FROM ENsupportersActivities WHERE type = 'B' AND datetime >= @start AND datetime <= @end)

    SELECT
      ROUND((@open / @total) * 100, 2) 'open',
      ROUND((@click / @total) * 100, 2) 'click',
      ROUND((@formsub / @total) * 100, 2) 'formsub',
      ROUND((@lstopen / @lsttotal) * 100, 2) 'lstopen',
      ROUND((@lstclick / @lsttotal) * 100, 2) 'lstclick',
      ROUND((@lstformsub / @lsttotal) * 100, 2) 'lstformsub'
    ")

  output = results.first

  send_event('EN_email_stats_open', { current: output['open'], last: output['lstopen'] })
  send_event('EN_email_stats_click', { current: output['click'], last: output['lstclick'] })
  send_event('EN_email_stats_formsub', { current: output['formsub'], last: output['lstformsub'] })

end
