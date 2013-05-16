require 'yaml'
require 'tiny_tds'

yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '60m', :first_in => 120 do |job|
  populartweets = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'])
  result = client.execute("
  USE externaldata

  SELECT TOP 5 usr_name, text, profile_image_url
  FROM tweets
  WHERE RIGHT(text,25) IN (
    SELECT TOP 5 RIGHT(text,25)
    FROM tweets
    WHERE
      text LIKE '%Amnesty%International%' AND
      imported >= DATEADD(WEEK, -1, GETDATE())
    GROUP BY RIGHT(text,25)
    ORDER BY COUNT(id) DESC)
  ORDER BY created DESC")

  result.each do |row|
    populartweets << {:name=>row['usr_name'], :body=>row['text'], :avatar=>row['profile_image_url']}
  end

  send_event('twitter_mentions_AIC', comments: populartweets)
end
