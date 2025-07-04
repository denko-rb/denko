#
# TM1637 is 4 seven-segment LEDS, plus a colon in the middle.
#
require 'bundler/setup'
require 'denko'

board  = Denko::Board.new(Denko::Connection::Serial.new)
tm1637 = Denko::LED::TM1637.new(board: board, pins: {clk: 4, dio: 5}, rotate: true)

# Digits are instances of LED::SevenSegment
# Access them directly
tm1637.digits[0].write "1"
tm1637.digits[1].write "2"
tm1637.digits[2].write "0"
tm1637.digits[3].write "0"

# Colon is a DigitalIO::Output
4.times do
  tm1637.colon.toggle
  sleep 0.25
end
tm1637.colon.on

# Toggle entire display on or off.
sleep 0.5
tm1637.off
sleep 0.5
tm1637.on

# Brightness control.
[1, 2, 4, 10, 11, 12, 13, 14].each do |b|
  tm1637.brightness = b
  sleep 0.25
end
tm1637.brightness = 10

# Write first 4 chars of a String to the digits.
last_time = nil
loop do
  this_time = Time.now.strftime("%l%M")
  if this_time != last_time
    tm1637.text(this_time)
    last_time = this_time
    sleep 0.02
  end
end
