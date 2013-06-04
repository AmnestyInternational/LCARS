#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'

def loadcountries
  countries = Hash.new {|hash,key| hash[key] = [] }

  yml = YAML::load(File.open('lib/countries.yml'))

  yml.each do | country |
    countries[country[1][:name]] << country[1][:name]
    
    if country[1][:adjectivals]
        country[1][:adjectivals].each { | adjective |
          countries[country[1][:name]] << adjective
        }
    end

    if country[1][:demonyms]
        country[1][:demonyms].each { | adjective |
          countries[country[1][:name]] << adjective
        }
    end
  end

  countries
end

def loadtweets
  yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])

  result = client.execute("
    SELECT text
    FROM vAI_CanadianTweets
    WHERE
      (text LIKE '%Amnesty%International%' OR
      text LIKE '%@Amnesty%') AND
      created > DATEADD(DAY, -7, GETDATE())")

  tweets = []

  result.each do | row |
    tweets << row['text']
  end

  tweets
end

def countoccurances(concepts, text) 
  conceptcount = Hash.new {|hash,key| hash[key] = 0 }
  
  concepts.each do | concept |
    regex = concept[1].join("|")
    text.each do | text |
      conceptcount[concept[0]] += 1 if text.match(/#{regex}/i)
    end
  end
 
  Hash[*conceptcount.sort_by {|k,v| -v}[0..6].flatten]
end

countries = loadcountries
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '120m', :first_in => 371 do |job|
  twitter_countries = []

  loadtweets

  countoccurances(countries, loadtweets).each do | row |
    twitter_countries << {:label=>row[0], :value=>row[1]}
  end

  send_event('Twitter_trending_countries', { items: twitter_countries })
end





