#
# Walk a single pixel along the length of an APA102 strip and back,
# changing color each time it returns to position 0.
#
require 'bundler/setup'
require 'denko'

RED    = [255, 0, 0]
GREEN  = [0, 255, 0]
BLUE   = [0, 0, 255]
WHITE  = [255, 255, 255]
COLORS = [RED, GREEN, BLUE, WHITE]
PIXELS = 8

# Move along the strip and back, one pixel at a time.
positions = (0..PIXELS-1).to_a + (1..PIXELS-2).to_a.reverse

# Use the default hardware SPI bus.
board = Denko::Board.new(Denko::Connection::Serial.new)
bus   = Denko::SPI::Bus.new(board: board)
strip = Denko::LED::APA102.new(bus: bus, length: PIXELS)

loop do
  COLORS.each do |color|
    positions.each do |index|
      strip.clear
      strip[index] = color
      strip.show
      sleep 0.025
    end
  end
end
