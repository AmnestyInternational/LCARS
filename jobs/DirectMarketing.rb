#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '30m', :first_in => 155 do |job|

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'], :timeout => 15000)
  result = client.execute("
    USE iMIS

    DECLARE @start DATE = DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)
    DECLARE @end DATE = DATEADD(DAY, -1, DATEADD(YEAR, 1, @start))

    --SELECT @start, @end

    DECLARE @AppealCodes TABLE
    (
      AppealCode VARCHAR(8) PRIMARY KEY,
      FirstDate DATE
    )

    INSERT INTO @AppealCodes
      SELECT SOURCE_CODE, MIN(TRANSACTION_DATE)
      FROM Activity
      WHERE PRODUCT_CODE LIKE 'DM%'
      GROUP BY SOURCE_CODE
      HAVING
        MIN(TRANSACTION_DATE) >= @start AND
        MIN(TRANSACTION_DATE) <= @end
      OPTION(RECOMPILE)
  
    --SELECT * FROM @AppealCodes

    SELECT
      Act.PRODUCT_CODE 'DM code',
      SUM(AMOUNT) 'Amount',
      COUNT(ID) 'Donations',
      ROUND(SUM(AMOUNT) / COUNT(ID), 2) 'Average'
    FROM
      Activity AS Act
    WHERE
      Act.PRODUCT_CODE LIKE 'DM%' AND
      Act.DESCRIPTION LIKE 'Direct%' AND
      Act.SOURCE_CODE IN (SELECT AppealCode FROM @AppealCodes)
    GROUP BY Act.PRODUCT_CODE
    ORDER BY CAST(RIGHT(Act.PRODUCT_CODE, LEN(Act.PRODUCT_CODE) - 2) AS INT)
    ")

  dm_amount = []
  result.each do | row |
    dm_amount << {:label=>row['DM code'], :value=>row['Amount'].to_f}
  end
  send_event('DM_codes_amount', { items: dm_amount })

  dm_donations = []
  result.each do | row |
    dm_donations << {:label=>row['DM code'], :value=>row['Donations'].to_f}
  end
  send_event('DM_codes_donations', { items: dm_donations })

  dm_averages = []
  result.each do | row |
    dm_averages << {:label=>row['DM code'], :value=>row['Average'].to_f}
  end
  send_event('DM_codes_averages', { items: dm_averages })

end

