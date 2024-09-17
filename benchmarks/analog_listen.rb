#
# Simple benchmark to see how much analog listen throughput is
# available from a Denko::Board instance.
#
# To find the limit, add more pins and reduce the divider until
# the rate per input pin can't meet the target.
#   Example: Rate per input pin is < 500 Hz when divider is 2 ms.
#
require 'bundler/setup'
require 'denko'

# In seconds
TEST_TIME = 30

# Millisecond interval for analog listeners
# Valid values: 1, 2, 4, 8, 16, 32, 64, 128
DIVIDER = 2

# Input pins to read
PINS = [:A0, :A1]

connection = Denko::Connection::Serial.new
board      = Denko::Board.new(connection)
inputs     = PINS.map { |pin| Denko::AnalogIO::Input.new(pin: pin, board: board) }

# No mutex. Denko::Board callbacks are sequential, regardless of Ruby engine.
$readings = 0
inputs.each do |input|
  input.add_callback { $readings += 1 }
  input.listen(DIVIDER)
end

print "Sampling for #{TEST_TIME} seconds... "

# Main test
start = Time.now
$readings = 0
sleep TEST_TIME
finish = Time.now
# Copy immediately to another variable before stopping inputs.
readings = $readings
inputs.each { |input| input.stop }

puts "Done."; puts

rps   = (readings / (finish - start))
rpspi = rps / inputs.count
puts "Total analog readings : #{readings}"
puts "Analog readings /s    : #{rps.round(3)}"
puts "Rate per input pin    : #{rpspi.round(3)} Hz"
