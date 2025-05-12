#
# Example using the SSD160 E-Paper over SPI.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::Bus.new(board: board)

# Must be connected to SPI bus CLK and MOSI pins, plus select, dc, reset and busy.
# Give colors: as total number of colors NOT including blank/white. Red and black = 2.
# When giving colors: 0 = clear, 1 = black, 2 = red
epaper = Denko::Display::SSD1680.new(bus: bus, pins: { select: 10, dc: 9, reset: 8 , busy: 7}, colors: 2)
canvas = epaper.canvas

# Hardware features
# epaper.reflect_x
# epaper.invert_black

# Draw some text on the canvas (a Ruby memory buffer).
baseline = 85
canvas.text_cursor = [56,baseline+35]
canvas.font = Denko::Fonts::LED_8x16
canvas.font_scale = 2
canvas.text "Hello World!"

# Add some shapes.
canvas.rectangle  20,  baseline, 76, -76, color: 2
canvas.circle     148, baseline-38, 38,   color: 2
tri_x = 200
canvas.triangle   tri_x, baseline, tri_x+76, baseline, tri_x+38, baseline-76,
                  color: 2

# 1px black border at screen edges. color: 1 when not given.
canvas.rectangle  0, 0, canvas.columns-1, canvas.rows-1

# Show it
epaper.draw
epaper.deep_sleep
board.finish_write
