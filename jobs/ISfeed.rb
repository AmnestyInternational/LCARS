#!/usr/bin/env ruby
require 'net/http'
require 'json'

SCHEDULER.every '10m', :first_in => 0 do |job|
  http = Net::HTTP.new('ajax.googleapis.com')
  response = http.request(Net::HTTP::Get.new("/ajax/services/feed/load?v=1.0&num=6&q=https://news.google.ca/news/feeds?q=Amnesty+International&hl=en&gl=ca&cr=countryCA&bav=on.2,or.r_qf.&bvm=bv.43828540,d.b2I&biw=1440&bih=813&um=1&ie=UTF-8&output=rss"))
  newsarticles = JSON.parse(response.body)['responseData']['feed']['entries']
 
  if newsarticles
    newsarticles.map! do |article| 
      { name: article['title'], body: article['contentSnippet'] }
    end

#     puts newsarticles.inspect

    send_event('is_feed', comments: newsarticles)
  end
end

# http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=6&q=https://news.google.ca/news/feeds?q=Amnesty+International&hl=en&gl=ca&cr=countryCA&bav=on.2,or.r_qf.&bvm=bv.43828540,d.b2I&biw=1440&bih=813&um=1&ie=UTF-8&output=rss

