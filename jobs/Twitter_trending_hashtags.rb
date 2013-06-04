#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '60m', :first_in => 39 do |job|
  twitter_trends = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
    USE externaldata
    SELECT TOP 7 TA.term, COUNT(TA.term) 'Count'
    FROM
      vAI_CanadianTweets AS T
      INNER JOIN
      tweetsanatomize AS TA
      ON T.id = TA.tweet_id
    WHERE
      TA.term LIKE '#%' AND
      T.text LIKE '%Amnesty%' AND
      T.created > DATEADD(DAY, -7, GETDATE()) AND
      TA.term NOT IN ('#Amnesty','#AmnestyInternational')
    GROUP BY TA.term
    ORDER BY COUNT(TA.term) DESC")

  result.each do |row|
    twitter_trends << {:label=>row['term'], :value=>row['Count']}
  end

  send_event('Twitter_trending_hashtags', { items: twitter_trends })


  twitter_trends = []
  result = client.execute("
    USE externaldata
    SELECT TOP 7 TA.term, COUNT(TA.term) 'Count'
    FROM
      vAI_CanadianTweets AS T
      INNER JOIN
      tweetsanatomize AS TA
      ON T.id = TA.tweet_id
    WHERE
      TA.term LIKE '#%' AND
      T.text NOT LIKE '%Amnesty%' AND
      T.text LIKE '%human%rights%' AND
      TA.term != '#humanrights' AND
      T.created > DATEADD(DAY, -7, GETDATE())
    GROUP BY TA.term
    ORDER BY COUNT(TA.term) DESC")

  result.each do |row|
    twitter_trends << {:label=>row['term'], :value=>row['Count']}
  end

  send_event('Twitter_trending_hashtags_HR_but_non_Amnesty', { items: twitter_trends })
end
