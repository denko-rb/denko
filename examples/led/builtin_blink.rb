#
# Blink example for standard built-in LEDs named :LED_BUILTIN
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
led = Denko::LED.new(board: board, pin: :LED_BUILTIN)

led.blink 0.5

sleep
