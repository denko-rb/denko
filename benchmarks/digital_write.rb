#
# Benchmark digital write throughput for a Denko::Board instance.
#
require 'bundler/setup'
require 'denko'

# Pins > 63 will not benefit from the single-byte message optimization.
PIN          = 4
TOTAL_WRITES = 200_000

connection = Denko::Connection::Serial.new
board      = Denko::Board.new(connection)
output     = Denko::DigitalIO::Output.new(board: board, pin: PIN)

print "Testing #{TOTAL_WRITES} digital writes... "

start = Time.now
(TOTAL_WRITES / 2).times do
  output.high
  output.low
end
board.finish_write
finish = Time.now

puts "Done."; puts

wps = TOTAL_WRITES / (finish - start)
puts "Digital writes per second : #{wps.round(3)}"
