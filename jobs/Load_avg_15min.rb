# Populate the graph with 0.00 results
require 'date'

def seconds_since_midnight
  (Time.now.hour * 3600) + (Time.now.min * 60) + (Time.now.sec)
end

starttime = seconds_since_midnight - (16 * 60 * 15)

points = []
(1..16).each do | i |
  points << { x: (i * 60 * 15) + starttime, y: 0 }
end

SCHEDULER.every '15m', :first_in => 19 do |job|
  points.shift
  uptime = %x('uptime')
  points << { x: seconds_since_midnight, y: uptime[-5..-2].to_f }

  send_event('Load_avg_15min', points: points)
end
