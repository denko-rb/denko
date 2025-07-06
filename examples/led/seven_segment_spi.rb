#
# Multiple LED::SevenSegment though series registers, like a 74HC595.
#
require 'bundler/setup'
require 'denko'

SELECT_PIN = 53

board     = Denko::Board.new(Denko::Connection::Serial.new)
bus       = Denko::SPI::Bus.new(board: board, index: 0)
ssd_array = Denko::LED::SevenSegmentSPI.new(bus: bus, pin: SELECT_PIN, digits: 4, inverted: true)

# Digits are instances of LED::SevenSegment
# Access them directly
ssd_array.digits.each { it.write "0" }
sleep 1

# Or write a string to them
ssd_array.text "1.234"
sleep 1

loop do
  ssd_array.text "1.234"
  sleep 0.5
  ssd_array.text "    "
  sleep 0.5
end
