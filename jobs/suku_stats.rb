#!/usr/bin/env ruby
require 'yaml'
require 'tiny_tds'
 
yml = YAML::load(File.open('lib/db_settings.yml'))['prod_settings']

SCHEDULER.every '35m', :first_in => 0 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    USE suku
    SELECT COUNT(DISTINCT(user_id)) 'Suku users'
    FROM sql_runner.query_logs
    WHERE user_id NOT IN (8,9)
  ")

  suku_users = result.first['Suku users']
  send_event('suku_users',   { value: suku_users })
end


SCHEDULER.every '35m', :first_in => 0 do |job|
  reports_per_user = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    USE suku
    SELECT (u.first_name + ' ' + u.last_name) 'User', SUM(ql.runs) 'Reports run'
    FROM
      sql_runner.query_logs AS ql
      INNER JOIN
      users AS u
      ON u.id = ql.user_id
      INNER JOIN
      sql_runner.report_queries AS rq
      ON rq.id = ql.report_query_id
    WHERE ql.user_id NOT IN (8,9)
    GROUP BY u.first_name, u.last_name
    ORDER BY 'Reports run' DESC
  ")

  result.each do |row|
    reports_per_user << {:label=>row['User'], :value=>row['Reports run']}
  end

  send_event('suku_reports_per_user', { items: reports_per_user })

end


SCHEDULER.every '35m', :first_in => 0 do |job|
  reports_per_tag = []

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    USE suku
    SELECT TOP 6 t.name 'Name', COUNT(qt.id) 'Count'
    FROM
      sql_runner.query_tags AS qt
      INNER JOIN
      sql_runner.tags AS t
      ON qt.tag_id = t.id
    GROUP BY t.name
    ORDER BY 'Count' DESC
  ")

  result.each do |row|
    reports_per_tag << {:label=>row['Name'], :value=>row['Count']}
  end

  send_event('suku_reports_per_tag', { items: reports_per_tag })

end


SCHEDULER.every '35m', :first_in => 0 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    USE suku
    SELECT COUNT(id) 'Scheduled reports'
    FROM sql_runner.scheduled_queries
  ")

  scheduled_reports = result.first['Scheduled reports']
  send_event('scheduled_reports',   { value: scheduled_reports })
end


SCHEDULER.every '37m', :first_in => 0 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  results = client.execute("
    USE suku

    SELECT (
      SELECT COUNT(user_id)
      FROM sql_runner.query_logs
      WHERE user_id NOT IN (8,9)
      ) 'reports run this week',
      (
      SELECT COUNT(user_id)
      FROM sql_runner.query_logs
      WHERE
        user_id NOT IN (8,9) AND
        updated_at < DATEADD(WEEK, -1, GETDATE())
      ) 'reports run last week'
      ")

  results =  results.first

  send_event('suku_manual_reports_run', { current: results['reports run this week'], last: results['reports run last week'] })
end


SCHEDULER.every '35m', :first_in => 0 do |job|

  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  result = client.execute("
    USE suku
    SELECT (
      SELECT COUNT(DISTINCT(user_id))
      FROM sql_runner.query_logs
      WHERE user_id NOT IN (8,9)
      ) 'Run reports',
      (
      SELECT COUNT(id)
      FROM users
      WHERE
        created_at != updated_at AND
        email LIKE '%@amnesty.ca' AND
        id NOT IN (8,9)
      ) 'Logged in',
      (
      SELECT COUNT(id)
      FROM users
      WHERE
        email LIKE '%@amnesty.ca' AND
        id NOT IN (8,9)
      ) 'Accounts created'
  ")

  result =  result.first
  suku_user_stats = []
  suku_user_stats << {:label => 'Run reports', :value => result['Run reports']} << {:label => 'Logged in', :value => result['Logged in']} << {:label => 'Accounts created', :value => result['Accounts created']}

  send_event('suku_user_stats', { items: suku_user_stats })

end



SCHEDULER.every '35m', :first_in => 0 do |job|
  client = TinyTds::Client.new(:username => yml['username'], :password => yml['password'], :host => yml['host'], :database => yml['database'])
  results = client.execute("
    USE suku
    SELECT (
      SELECT COUNT(id)
      FROM sql_runner.scheduled_queries
      ) 'Scheduled reports this week',
      (
      SELECT COUNT(id)
      FROM sql_runner.scheduled_queries
      WHERE
        created_at < DATEADD(WEEK, -1, GETDATE())
      ) 'Scheduled reports last week'
  ")

  results =  results.first

  send_event('suku_scheduled_reports', { current: results['Scheduled reports this week'], last: results['Scheduled reports last week'] })
end





