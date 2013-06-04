#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '10m', :first_in => 355 do |job|
  tweetusers = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
    USE externaldata

    SELECT TOP 18 TA.term 'user', COUNT(DISTINCT(TA.tweet_id)) 'RTCount'
    FROM
      vAI_CanadianTweets AS T1
      INNER JOIN
      TweetsAnatomize AS TA
      ON '@' + T1.usr = TA.term
      INNER JOIN
      vAI_CanadianTweets AS T2
      ON TA.tweet_id = T2.id
    WHERE
      T2.text LIKE 'RT%Amnesty%International%' AND
      T2.created >= DATEADD(DAY, -30, GETDATE())
    GROUP BY TA.term
    ORDER BY RTCount DESC")

  result.each do |row|
    tweetusers << {:label=>row['user'], :value=>row['RTCount']}
  end

  send_event('Twitter_Influential_Users', { items: tweetusers })

end
