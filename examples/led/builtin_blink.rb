#
# Blink example for standard built-in LEDs named :LED_BUILTIN
#
require 'bundler/setup'
require 'denko'

PIN = :LED_BUILTIN

board = Denko::Board.new(Denko::Connection::Serial.new)
led = Denko::LED.new(board: board, pin: PIN)

led.blink 0.5

sleep
