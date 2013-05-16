# Populate the graph with 0.00 results
points = []
(1..10).each do |i|
  points << { x: i, y: 0 }
end
last_x = points.last[:x]

SCHEDULER.every '1m', :first_in => 45 do |job|
  points.shift
  last_x += 1
  uptime = %x('uptime')
  points << { x: last_x, y: uptime[-17..-14].to_f }

  send_event('Load_avg_1min', points: points)
end
