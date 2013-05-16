#!/usr/bin/env ruby
require 'net/http'
require 'json'

SCHEDULER.every '10m', :first_in => 120 do |job|
  http = Net::HTTP.new('ajax.googleapis.com')
  response = http.request(Net::HTTP::Get.new("/ajax/services/feed/load?v=1.0&num=10&q=http://www.fpinfomart.ca/clip/rss/bbertonhunter/398427/"))
  newsarticles = JSON.parse(response.body)['responseData']['feed']['entries']
 
  if newsarticles
    newsarticles.map! do |article| 
      { name: article['title'], body: article['contentSnippet'] }
    end

#     puts newsarticles.inspect

    send_event('RSS_feed_infomart', comments: newsarticles)
  end
end

# http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=10&q=http://www.fpinfomart.ca/clip/rss/bbertonhunter/398427/

