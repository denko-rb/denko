#
# Fade test for APA102 LED strip.
#
require 'bundler/setup'
require 'denko'

RED    = [255, 0, 0]
GREEN  = [0, 255, 0]
BLUE   = [0, 0, 255]
WHITE  = [255, 255, 255]
COLORS = [RED, GREEN, BLUE, WHITE]
PIXELS = 4

# Get all the brightness values as an array.
brightness_steps = (0..31).to_a + (1..30).to_a.reverse

# Use the default hardware SPI bus.
board = Denko::Board.new(Denko::Connection::Serial.new)
bus   = Denko::SPI::Bus.new(board: board)
strip = Denko::LED::APA102.new(bus: bus, length: PIXELS)

strip[0] = RED
strip[1] = GREEN
strip[2] = BLUE
strip[3] = WHITE

# Fade all 4 in sync using global brightness control.
brightness_steps.each do |value|
  strip.brightness = value
  strip.show
  sleep 0.05
end

# Set 4th pixel back to full brightness white.
strip[3] = WHITE + [31]

# Fade per-pixel, in different directions.
brightness_steps.cycle do |value|
  strip[0] = RED   +  [value]
  strip[1] = GREEN +  [31 - value]
  strip[2] = BLUE  +  [value]
  strip.show
  sleep 0.025
end
