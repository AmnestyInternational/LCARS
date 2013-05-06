#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('../suku_config/db_settings.yml'))

SCHEDULER.every '10m', :first_in => 0 do |job|
  fbpagestat = []

  client = TinyTds::Client.new(:username => yml['prod_settings']['username'], :password => yml['prod_settings']['password'], :host => yml['prod_settings']['host'])
  result = client.execute("USE externaldata
SELECT TOP 18 LEFT(fpp.message, 16) + '...' 'message', MAX(fpps.share_count) 'shares', fpp.created_time
FROM
fb_page_post AS fpp
INNER JOIN
fb_page_post_stat AS fpps
ON fpp.post_id = fpps.post_id
WHERE fpp.type IN ('247','80')
GROUP BY fpp.message, fpp.created_time 
ORDER BY fpp.created_time DESC")

  result.each do |row|
    fbpagestat << {:label=>row['message'], :value=>row['shares']}
  end

  send_event('fbpagestat', { items: fbpagestat })

end
