#
# Blink example for the LOLIN ESP32 S3 or C3, or any board where
# :LED_BUILTIN is the data pin for a single on-board WS2812.
#
require 'bundler/setup'
require 'denko'

PIN   = :LED_BUILTIN
WHITE = [255, 255, 255]
OFF   = [0, 0, 0]

board = Denko::Board.new(Denko::Connection::Serial.new)
strip = Denko::LED::WS2812.new(board: board, pin: PIN, length: 1)

loop do
  strip[0] = WHITE
  strip.show
  sleep 0.5
  strip[0] = OFF
  strip.show
  sleep 0.5
end
