#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']


SCHEDULER.every '10m', :first_in => 21 do |job|
  recenttweets = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    -- Twitter_Canadian_Pussy_Riot_tweets
    SELECT TOP 7 screen_name, text, profile_image_url
    FROM vAI_CanadianTweets
    WHERE
     text LIKE '%pussy%riot%'
    ORDER BY created DESC")

  result.each do |row|
    recenttweets << { :name=>row['usr_name'], :body=>row['text'], :avatar=>row['profile_image_url'] }
  end

  send_event('Twitter_Canadian_Pussy_Riot_tweets', comments: recenttweets)
end



SCHEDULER.every '30m', :first_in => 42 do |job|
  trendingwords = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    -- Twitter_Canadian_Pussy_Riot_trending_terms_1d
    SELECT TOP 7 TA.term 'Term', COUNT(TA.term) 'Count'
    FROM
      vAI_CanadianTweets AS CT
      INNER JOIN
      tweetsanatomize AS TA
      ON CT.id = TA.tweet_id
    WHERE
      CT.created > DATEADD(DAY, -1, GETDATE()) AND
      CT.text LIKE '%pussy%riot%'
    GROUP BY TA.term
    ORDER BY COUNT(TA.term) DESC")

  result.each do |row|
    trendingwords << { :label=>row['Term'], :value=>row['Count'] }
  end

  send_event('Twitter_Canadian_Pussy_Riot_trending_terms_1d', { items: trendingwords })
end



SCHEDULER.every '30m', :first_in => 55 do |job|
  trendinghashtags = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
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
    ORDER BY COUNT(TH.hashtag) DESC")

  result.each do |row|
    trendinghashtags << { :label=>row['Hashtag'], :value=>row['Count'] }
  end

  send_event('Twitter_Canadian_Pussy_Riot_trending_hashtags_1d', { items: trendinghashtags })
end



SCHEDULER.every '30m', :first_in => 34 do |job|
  trendingusermentions = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
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
    ORDER BY COUNT(TU.screen_name) DESC")

  result.each do |row|
    trendingusermentions << { :label=>row['User'], :value=>row['Count'] }
  end

  send_event('Twitter_Canadian_Pussy_Riot_trending_user_metions_1d', { items: trendingusermentions })
end



SCHEDULER.every '30m', :first_in => 53 do |job|
  influentialusers = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    -- Twitter_Canadian_Pussy_Riot_influential_users_1d
    SELECT TOP 18 '@' + screen_name 'screen_name', followers_count
    FROM vAI_CanadianTweets
    WHERE
      created > DATEADD(DAY, -1, GETDATE()) AND
      text LIKE '%pussy%riot%' AND
      followers_count > 100
    ORDER BY followers_count DESC")

  result.each do |row|
    influentialusers << { :label=>row['screen_name'], :value=>row['followers_count'] }
  end

  send_event('Twitter_Canadian_Pussy_Riot_influential_users_1d', { items: influentialusers })
end



SCHEDULER.every '30m', :first_in => 63 do |job|
  retweetedusers = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'], :timeout => 120000)
  result = client.execute("
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
    ORDER BY RTCount DESC")

  result.each do |row|
    retweetedusers << {:label=>row['user'], :value=>row['RTCount']}
  end

  send_event('Twitter_Canadian_Pussy_Riot_retweeted_users_1d', { items: retweetedusers })

end



SCHEDULER.every '10m', :first_in => 47 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'], :timeout => 120000)
  results = client.execute("
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
        created > DATEADD(MINUTE, -120, GETDATE())) 'previoushour'")

  tweetscount = results.first

  send_event('Twitter_Canadian_Pussy_Riot_tweets_per_hour', { current: tweetscount['lasthour'], last: tweetscount['previoushour'] })
end


=begin
SCHEDULER.every '30m', :first_in => 5 do |job|
  http = Net::HTTP.new('ajax.googleapis.com')
  response = http.request(Net::HTTP::Get.new("/ajax/services/feed/load?v=1.0&q=https://news.google.ca/news/feeds?q=pussy+riot&hl=en&gl=ca&authuser=0&cr=countryCA&bav=on.2,or.r_cp.r_qf.&bvm=bv.49478099,d.aWM,pv.xjs.s.en_US.c75bKy5EQ0A.O&biw=1680&bih=963&um=1&ie=UTF-8&output=rss"))
  newsarticles = JSON.parse(response.body)['responseData']['feed']['entries']
 
  if newsarticles
    newsarticles.map! do |article| 
      { name: article['title'], body: article['contentSnippet'] }
    end
  
    send_event('Google_News_feed_Pussy_Riot', comments: newsarticles)
  end
end

# http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q=https://news.google.ca/news/feeds?q=pussy+riot&hl=en&gl=ca&authuser=0&cr=countryCA&bav=on.2,or.r_cp.r_qf.&bvm=bv.49478099,d.aWM,pv.xjs.s.en_US.c75bKy5EQ0A.O&biw=1680&bih=963&um=1&ie=UTF-8&output=rss
=end


SCHEDULER.every '30m', :first_in => 36 do |job|
  tweetspercity = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'], :timeout => 120000)
  result = client.execute("
    -- Twitter_Canadian_Pussy_Riot_Tweets_per_city
    SELECT region 'City', COUNT(id) 'Count'
    FROM vAI_CanadianTweets
    WHERE
      text LIKE '%pussy%riot%'
    GROUP BY region
   ORDER BY COUNT(id) DESC")

  result.each do |row|
    tweetspercity << {:label=>row['City'], :value=>row['Count']}
  end

  send_event('Twitter_Canadian_Pussy_Riot_Tweets_per_city', { items: tweetspercity })

end




SCHEDULER.every '30m', :first_in => 76 do |job|
  canadianartiststweetcount = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'], :timeout => 120000)
  result = client.execute("
    -- Twitter_Canadian_Pussy_Riot_artists
    SELECT TU.name, COUNT(T.id) 'Count'
    FROM
      Tweets AS T
      INNER JOIN
      TwitterUsers AS TU
      ON T.usr_id = TU.id
    WHERE
      TU.screen_name IN ('arcadefire','bryanadams','morissette','hidden_cameras','peachesnisker') AND
      (T.text LIKE '%pussy%riot%' OR T.text LIKE '%amnesty%') AND
      T.created > DATEADD(DAY, -2, GETDATE())
    GROUP BY TU.name
    ORDER BY Count DESC")

  result.each do |row|
    canadianartiststweetcount << {:label=>row['name'], :value=>row['Count']}
  end

  send_event('Twitter_Canadian_Pussy_Riot_artists', { items: canadianartiststweetcount })

end



def seconds_since_midnight
  (Time.now.hour * 3600) + (Time.now.min * 60) + (Time.now.sec)
end

starttime = seconds_since_midnight - (36 * 60 * 10)

points = []
(1..36).each do | i |
  points << { x: (i * 60 * 10) + starttime, y: 0 }
end

SCHEDULER.every '10m', :first_in => 25 do |job|
  points.shift

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    SELECT COUNT(DISTINCT(usr_id)) 'count'
    FROM vAI_CanadianTweets
    WHERE
      text LIKE '%pussy%riot%' AND
      created > DATEADD(MINUTE, -10, GETDATE())")

  points << { x: seconds_since_midnight, y: result.first['count'] }

  send_event('Twitter_Canadian_Pussy_Riot_count', points: points)

end
