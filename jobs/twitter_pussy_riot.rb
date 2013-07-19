#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

=begin
-- SQL

-- Twitter_Canadian_Pussy_Riot_tweets_1h
SELECT TOP 10 *
FROM vAI_CanadianTweets
WHERE
  text LIKE '%pussy%riot%' AND
  created > DATEADD(HOUR, -1, GETDATE())
ORDER BY followers_count DESC


-- Twitter_Canadian_Pussy_Riot_trending_terms_1d
SELECT TOP 7 TA.term, COUNT(TA.term) 'Count'
FROM
  vAI_CanadianTweets AS CT
  INNER JOIN
  tweetsanatomize AS TA
  ON CT.id = TA.tweet_id
WHERE
  CT.created > DATEADD(DAY, -1, GETDATE()) AND
  CT.text LIKE '%pussy%riot%'
GROUP BY TA.term
ORDER BY COUNT(TA.term) DESC


-- Twitter_Canadian_Pussy_Riot_trending_hashtags_1d
SELECT TOP 7 '#' + TH.hashtag 'Hashtag', COUNT(CT.usr_id) 'Count'
FROM 
  vAI_CanadianTweets AS CT
  INNER JOIN
  TweetHashtags AS TH
  ON CT.id = TH.tweet_id
WHERE
  CT.created > DATEADD(DAY, -1, GETDATE()) AND
  CT.text LIKE '%pussy%riot%'
GROUP BY TH.hashtag
ORDER BY COUNT(TH.hashtag) DESC


-- Twitter_Canadian_Pussy_Riot_trending_user_metions_1d
SELECT TOP 7 '@' + TU.screen_name 'User', COUNT(CT.usr_id) 'Count'
FROM 
  vAI_CanadianTweets AS CT
  INNER JOIN
  TweetUserMentions AS TUM
  ON CT.id = TUM.tweet_id
  INNER JOIN
  TwitterUsers AS TU
  ON TUM.usr_id = TU.id
WHERE
  CT.created > DATEADD(DAY, -1, GETDATE()) AND
  CT.text LIKE '%pussy%riot%'
GROUP BY TU.screen_name
ORDER BY COUNT(TU.screen_name) DESC

-- Twitter_Canadian_Pussy_Riot_influential_users_1d
SELECT TOP 7 screen_name, followers_count
FROM vAI_CanadianTweets
WHERE
  created > DATEADD(DAY, -1, GETDATE()) AND
  text LIKE '%pussy%riot%'
ORDER BY followers_count DESC


-- Twitter_Canadian_Pussy_Riot_retweeted_users_1d
SELECT TOP 7 TA.term 'user', COUNT(DISTINCT(TA.tweet_id)) 'RTCount'
FROM
  vAI_CanadianTweets AS T1
  INNER JOIN
  TweetsAnatomize AS TA
  ON '@' + T1.screen_name = TA.term
  INNER JOIN
  vAI_CanadianTweets AS T2
  ON TA.tweet_id = T2.id
WHERE
  T2.text LIKE 'RT%pussy%riot%' AND
  T2.created >= DATEADD(DAY, -1, GETDATE())
GROUP BY TA.term
ORDER BY RTCount DESC


-- Twitter_Canadian_Pussy_Riot_tweets_per_hour
SELECT 
  (
    SELECT COUNT(DISTINCT(usr_id))
    FROM vAI_CanadianTweets
    WHERE
      text LIKE '%pussy%riot%' AND
      created > DATEADD(MINUTE, -60, GETDATE())) 'lasthour',
  (
    SELECT COUNT(DISTINCT(usr_id))
    FROM vAI_CanadianTweets
    WHERE
      text LIKE '%pussy%riot%' AND
      created < DATEADD(MINUTE, -60, GETDATE()) AND
      created > DATEADD(MINUTE, -120, GETDATE())) 'previoushour'

=end
