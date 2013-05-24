# Populate the graph with 0.00 results
points = []
(1..240).each do |i|
  points << { x: i * 60, y: 0 }
end
last_x = points.last[:x]

SCHEDULER.every '1m', :first_in => 17 do |job|
  points.shift
  last_x += 60
  uptime = %x('uptime')
  points << { x: last_x, y: uptime[-17..-14].to_f }

  send_event('Load_avg_1min', points: points)
end
