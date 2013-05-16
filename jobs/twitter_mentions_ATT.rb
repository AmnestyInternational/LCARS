require 'net/http'
require 'json'

hash_term = URI::encode('#ArmsTradeTreaty')
geocode = URI::encode('46.581518,-78.530273,250km')
result_type = URI::encode('mixed')

SCHEDULER.every '15m', :first_in => 120 do |job|
  http = Net::HTTP.new('search.twitter.com')
  response = http.request(Net::HTTP::Get.new("/search.json?geocode=#{geocode}&result_type=#{result_type}&q=#{hash_term}"))
  tweets = JSON.parse(response.body)["results"]
  if tweets
    tweets.map! do |tweet| 
      { name: tweet['from_user'], body: tweet['text'], avatar: tweet['profile_image_url_https'] }
    end

    send_event('twitter_mentions_ATT', comments: tweets)
  end
end

# the above code queries this url
# http://search.twitter.com/search.json?geocode=46.581518,-78.530273,250km&result_type=popular&q=%23ArmsTreaty


