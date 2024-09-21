#
# Blink example for standard built-in LEDs named :LED_BUILTIN
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
led = Denko::LED.new(board: board, pin: :LED_BUILTIN)

min = 0
max = 255
values = (min..max).to_a + (min..max-1).to_a.reverse

values.cycle do |value|
  led.write(value)
  sleep 0.005
end
