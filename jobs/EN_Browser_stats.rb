#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '10m', :first_in => 0 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    DECLARE @since DATE = DATEADD(DAY, -30, GETDATE())
    DECLARE @Chrome FLOAT = (SELECT COUNT(DISTINCT(supporter_id)) FROM ENsupportersActivities WHERE datetime > @since AND data18 LIKE '%mobile:N~tablet:N%browser:%Chrome%')
    DECLARE @Firefox FLOAT = (SELECT COUNT(DISTINCT(supporter_id)) FROM ENsupportersActivities WHERE datetime > @since AND data18 LIKE '%mobile:N~tablet:N%browser:%Firefox%')
    DECLARE @Explorer FLOAT = (SELECT COUNT(DISTINCT(supporter_id)) FROM ENsupportersActivities WHERE datetime > @since AND data18 LIKE '%mobile:N~tablet:N%browser:%Explorer%')
    DECLARE @Safari FLOAT = (SELECT COUNT(DISTINCT(supporter_id)) FROM ENsupportersActivities WHERE datetime > @since AND data18 LIKE '%mobile:N~tablet:N%browser:%Safari%')
    DECLARE @unknown FLOAT = (SELECT COUNT(DISTINCT(supporter_id)) FROM ENsupportersActivities WHERE datetime > @since AND data18 LIKE '%mobile:N~tablet:N%browser:Unknown')
    DECLARE @total FLOAT = @Chrome + @Firefox + @Explorer + @Safari + @unknown

    SELECT
      ROUND(@Explorer / @total * 100, 1) 'IE',
      ROUND(@Firefox / @total * 100, 1) 'Firefox',
      ROUND(@Chrome / @total * 100, 1) 'Chrome',
      ROUND(@Safari / @total * 100, 1) 'Safari',
      ROUND(@unknown / @total * 100, 1) 'Unknown'
    ")

  browserstats = []

  result.each do | row |
    row.each do | field |
      browserstats << {:label=>field[0], :value=>field[1]}
    end
  end

  send_event('EN_browser_stats', { items: browserstats })
end

#{"IE"=>27.5, "Firefox"=>23.9, "Chrome"=>20.9, "Safari"=>11.0, "Unknown"=>16.7}

