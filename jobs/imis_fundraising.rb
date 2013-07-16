#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'

def to_currency(n)
  a,b = sprintf("%0.2f", n).split('.')
  a.gsub!(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')
  "$#{a}.#{b}"
end


yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '30m', :first_in => 152 do |job|

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


SCHEDULER.every '30m', :first_in => 167 do |job|

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'], :timeout => 15000)
  result = client.execute("
    USE iMIS

    SELECT
      Act.PRODUCT_CODE 'AM code',
      SUM(AMOUNT) 'Amount',
      COUNT(ID) 'Donations',
      SUM(AMOUNT) / COUNT(ID) 'Average'
    FROM
      Activity AS Act
    WHERE
      Act.PRODUCT_CODE LIKE 'AM%' AND
      ACT.CAMPAIGN_CODE LIKE ('%' + CONVERT(VARCHAR,YEAR(GETDATE())))
    GROUP BY Act.PRODUCT_CODE
    ORDER BY CAST(RIGHT(Act.PRODUCT_CODE, LEN(Act.PRODUCT_CODE) - 2) AS INT)
    ")

  am_amount = []
  result.each do | row |
    am_amount << {:label=>row['AM code'], :value=>to_currency(row['Amount'])}
  end
  send_event('AM_codes_amount', { items: am_amount })

  am_donations = []
  result.each do | row |
    am_donations << {:label=>row['AM code'], :value=>row['Donations']}
  end
  send_event('AM_codes_donations', { items: am_donations })

  am_averages = []
  result.each do | row |
    am_averages << {:label=>row['AM code'], :value=>to_currency(row['Average'])}
  end
  send_event('AM_codes_averages', { items: am_averages })

end


SCHEDULER.every '30m', :first_in => 3 do |job|

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'], :timeout => 15000)
  result = client.execute("
    USE iMIS

    SELECT
      Act.PRODUCT_CODE 'BB code',
      SUM(AMOUNT) 'Amount',
      COUNT(ID) 'Donations',
      SUM(AMOUNT) / COUNT(ID) 'Average'
    FROM
      Activity AS Act
    WHERE
      Act.PRODUCT_CODE LIKE 'BB%' AND
      ACT.CAMPAIGN_CODE LIKE ('%' + CONVERT(VARCHAR,YEAR(GETDATE())))
    GROUP BY Act.PRODUCT_CODE
    ORDER BY CAST(RIGHT(Act.PRODUCT_CODE, LEN(Act.PRODUCT_CODE) - 2) AS INT)
    ")

  bb_amount = []
  result.each do | row |
    bb_amount << {:label=>row['BB code'], :value=>to_currency(row['Amount'])}
  end
  send_event('BB_codes_amount', { items: bb_amount })

  bb_donations = []
  result.each do | row |
    bb_donations << {:label=>row['BB code'], :value=>row['Donations']}
  end
  send_event('BB_codes_donations', { items: bb_donations })

  bb_averages = []
  result.each do | row |
    bb_averages << {:label=>row['BB code'], :value=>to_currency(row['Average'])}
  end
  send_event('BB_codes_averages', { items: bb_averages })

end


SCHEDULER.every '30m', :first_in => 3 do |job|

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'], :timeout => 15000)
  result = client.execute("
    USE iMIS

    SELECT
      Act.PRODUCT_CODE 'WM code',
      SUM(AMOUNT) 'Amount',
      COUNT(ID) 'Donations',
      SUM(AMOUNT) / COUNT(ID) 'Average'
    FROM
      Activity AS Act
    WHERE
      Act.PRODUCT_CODE LIKE 'WM%' AND
      ACT.CAMPAIGN_CODE LIKE ('%' + CONVERT(VARCHAR,YEAR(GETDATE())))
    GROUP BY Act.PRODUCT_CODE
    ORDER BY CAST(RIGHT(Act.PRODUCT_CODE, LEN(Act.PRODUCT_CODE) - 2) AS INT)
    ")

  wm_amount = []
  result.each do | row |
    wm_amount << {:label=>row['WM code'], :value=>to_currency(row['Amount'])}
  end
  send_event('WM_codes_amount', { items: wm_amount })

  wm_donations = []
  result.each do | row |
    wm_donations << {:label=>row['WM code'], :value=>row['Donations']}
  end
  send_event('WM_codes_donations', { items: wm_donations })

  wm_averages = []
  result.each do | row |
    wm_averages << {:label=>row['WM code'], :value=>to_currency(row['Average'])}
  end
  send_event('WM_codes_averages', { items: wm_averages })

end
