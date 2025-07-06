#
# TM1637 is 4 seven-segment LEDS, plus a colon in the middle.
#
require 'bundler/setup'
require 'denko'

board  = Denko::Board.new(Denko::Connection::Serial.new)
tm1638 = Denko::LED::TM1638.new(board: board, pins: {clk: 4, dio: 5, stb: 6})

# Digits are instances of LED::SevenSegment
# Access them directly
tm1638.digits.each { it.write "0" }
sleep 1

# Or write a string to them
tm1638.text "12.345678"
sleep 1

# Toggle entire display on or off.
sleep 0.5
tm1638.off
sleep 0.5
tm1638.on

# Brightness control.
[1, 2, 4, 10, 11, 12, 13, 14].each do |b|
  tm1638.brightness = b
  sleep 0.25
end
tm1638.brightness = 10

# Write up to first 8 chars of a String to the digits.
tm1638.text "test1234"

# Control the discrete LEDS.
arr = (0..7).to_a + (1..6).to_a.reverse
previous = 0
arr.cycle do |i|
  tm1638.leds[previous].off
  tm1638.leds[i].on
  sleep 0.05
  previous = i
end
