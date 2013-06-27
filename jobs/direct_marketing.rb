#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'

def to_currency(n)
  a,b = sprintf("%0.2f", n).split('.')
  a.gsub!(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')
  "$#{a}.#{b}"
end

 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '30m', :first_in => 183 do |job|

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'], :timeout => 15000)
  result = client.execute("
    USE iMIS

    SELECT
      Act.PRODUCT_CODE 'DM code',
      SUM(AMOUNT) 'Amount',
      COUNT(ID) 'Donations',
      SUM(AMOUNT) / COUNT(ID) 'Average'
    FROM
      Activity AS Act
    WHERE
      Act.PRODUCT_CODE LIKE 'DM%' AND
      Act.DESCRIPTION LIKE 'Direct%' AND
      ACT.CAMPAIGN_CODE LIKE ('%' + CONVERT(VARCHAR,YEAR(GETDATE())))
    GROUP BY Act.PRODUCT_CODE
    ORDER BY CAST(RIGHT(Act.PRODUCT_CODE, LEN(Act.PRODUCT_CODE) - 2) AS INT)
    ")

  dm_amount = []
  result.each do | row |
    dm_amount << {:label=>row['DM code'], :value=>to_currency(row['Amount'])}
  end
  send_event('DM_codes_amount', { items: dm_amount })

  dm_donations = []
  result.each do | row |
    dm_donations << {:label=>row['DM code'], :value=>row['Donations']}
  end
  send_event('DM_codes_donations', { items: dm_donations })

  dm_averages = []
  result.each do | row |
    dm_averages << {:label=>row['DM code'], :value=>to_currency(row['Average'])}
  end
  send_event('DM_codes_averages', { items: dm_averages })

end

