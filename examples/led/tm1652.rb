#
# TM1637 is 4 seven-segment LEDS, plus a colon in the middle.
#
require 'bundler/setup'
require 'denko'

board  = Denko::Board.new(Denko::Connection::Serial.new)
uart   = Denko::UART::Hardware.new(board: board, index: 1, baud: 19200, config: "8O1")
tm1652 = Denko::LED::TM1652.new(board: board, uart: uart)

# Digits are instances of LED::SevenSegment
# Access them directly
tm1652.digits[0].write "1"
tm1652.digits[1].write "2"
tm1652.digits[2].write "0"
tm1652.digits[3].write "0"

# Colon is a DigitalIO::Output
4.times do
  tm1652.colon.toggle
  sleep 0.50
end
tm1652.colon.on

# Toggle entire display on or off.
sleep 0.5
tm1652.off
sleep 0.5
tm1652.on

# Brightness control
(0..15).each do |b|
  tm1652.duty_ratio = b
  sleep 0.25
end

(1..8).each do |b|
  tm1652.drive_current = b
  sleep 0.25
end

# Write first 4 chars of a String to the digits.
last_time = nil
loop do
  this_time = Time.now.strftime("%l%M")
  if this_time != last_time
    tm1652.text(this_time)
    last_time = this_time
    sleep 0.02
  end
end
