#
# Benchmark digital write throughput for a Denko::Board instance.
#
require 'bundler/setup'
require 'denko'

# Because the protocol is still ASCII, a single-digit pin may
# be faster than a double-digit, if serial I/O is the bottleneck.
PIN          = 4
TOTAL_WRITES = 20_000

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
