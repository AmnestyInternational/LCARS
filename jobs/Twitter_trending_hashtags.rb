#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '60m', :first_in => 600 do |job|
  twitter_trends = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
    USE externaldata
    SELECT TOP 7 TA.term, COUNT(TA.term) 'Count'
    FROM
      tweets AS T
      INNER JOIN
      tweetsanatomize AS TA
      ON T.id = TA.tweet_id
    WHERE
      TA.term LIKE '#%' AND
      T.text LIKE '%Amnesty%International%'
    GROUP BY TA.term
    ORDER BY COUNT(TA.term) DESC")

  result.each do |row|
    twitter_trends << {:label=>row['term'], :value=>row['Count']}
  end

  send_event('Twitter_trending_hashtags', { items: twitter_trends })
end
