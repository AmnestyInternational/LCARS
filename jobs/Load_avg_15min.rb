# Populate the graph with 0.00 results
points = []
(1..16).each do |i|
  points << { x: i * 60 * 15, y: 0 }
end
last_x = points.last[:x]

SCHEDULER.every '15m', :first_in => 19 do |job|
  points.shift
  last_x += 60 * 15
  uptime = %x('uptime')
  points << { x: last_x, y: uptime[-5..-2].to_f }

  send_event('Load_avg_15min', points: points)
end
