# Populate the graph with 0.00 results
require 'date'

def seconds_since_midnight
  (Time.now.hour * 3600) + (Time.now.min * 60) + (Time.now.sec)
end

starttime = seconds_since_midnight - (240 * 60)

points = []
(1..240).each do | i |
  points << { x: (i * 60) + starttime, y: 0 }
end

SCHEDULER.every '1m', :first_in => 0 do |job|
  points.shift
  uptime = %x('uptime')
  points << { x: seconds_since_midnight, y: uptime[-17..-14].to_f }

  send_event('Load_avg_1min', points: points)
end
