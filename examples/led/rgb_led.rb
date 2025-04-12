#
# A standard 3 pin RGB LED (not single pin addressable), on 3 PWM pins.
#
require 'bundler/setup'
require 'denko'

RED_PIN   = 11
GREEN_PIN = 10
BLUE_PIN  = 9

board  = Denko::Board.new(Denko::Connection::Serial.new)
rgb_led = Denko::LED::RGB.new board: board,
                              pins: {red: RED_PIN, green: GREEN_PIN, blue: BLUE_PIN}

# Set these predefined colors with symbols.
[:red, :green, :blue, :cyan, :yellow, :magenta, :white, :off].each do |color|
  rgb_led.color = color
  sleep 0.5
end

# RGB LED colors can be set as duty cycle (percentage) or 8-bit
# values (0-255), regarldess of actuall PWM bit depth.
#
loop do
  rgb_led.write(100, 50, 0)
  sleep 0.5
  rgb_led.write_8_bit(255, 0, 128)
  sleep 0.5
end
