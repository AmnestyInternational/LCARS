#!/usr/bin/env ruby
require 'net/http'
require 'json'

# The url you are tracking
sharedlink = URI::encode('amnesty.ca')

SCHEDULER.every '10m', :first_in => 1 do |job|
  fbstat = []

  http = Net::HTTP.new('graph.facebook.com')
  response = http.request(Net::HTTP::Get.new("/fql?q=SELECT%20share_count,%20like_count,%20comment_count,%20total_count%20FROM%20link_stat%20WHERE%20url=%22#{sharedlink}%22"))
  fbcounts = JSON.parse(response.body)['data']

  fbcounts[0].each do |stat|
    fbstat << {:label=>stat[0], :value=>stat[1]}
  end

   send_event('Facebook_link_stat', { items: fbstat })

end

# https://graph.facebook.com/fql?q=SELECT%20url,%20normalized_url,%20share_count,%20like_count,%20comment_count,%20total_count,commentsbox_count,%20comments_fbid,%20click_count%20FROM%20link_stat%20WHERE%20url=%22amnesty.ca%22
# https://graph.facebook.com/fql?q=SELECT%20share_count,%20like_count,%20comment_count,%20total_count,%20click_count%20FROM%20link_stat%20WHERE%20url=%22amnesty.ca%22


