#
# Walk a pixel along a WS2812 strip and back, changing color each loop.
#
require 'bundler/setup'
require 'denko'

WS2812_PIN = 4
PIXELS     = 8

RED    = [255, 0, 0]
GREEN  = [0, 255, 0]
BLUE   = [0, 0, 255]
WHITE  = [255, 255, 255]
COLORS = [RED, GREEN, BLUE, WHITE]

positions = (0..PIXELS-1).to_a + (1..PIXELS-2).to_a.reverse

board = Denko::Board.new(Denko::Connection::Serial.new)
strip = Denko::LED::WS2812.new(board: board, pin: WS2812_PIN, length: PIXELS)

loop do
  COLORS.each do |color|
    positions.each do |index|
      strip.clear
      strip[index] = color
      strip.show
      sleep 0.05
    end
  end
end
