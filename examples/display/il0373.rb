#
# Example using the IL0373 E-Paper over SPI.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::Bus.new(board: board)

# Must be connected to SPI bus CLK and MOSI pins, plus select, dc, reset and busy.
epaper = Denko::Display::IL0373.new(bus: bus, pins: { select: 10, dc: 9, reset: 8 , busy: 7})
canvas = epaper.canvas

# Hardware features
# paper.reflect_x
# epaper.reflect_y
# epaper.rotate
# epaper.invert_black

# Draw some text on the canvas (a Ruby memory buffer).
baseline = 66
canvas.text_cursor = [14,baseline+34]
canvas.font = Denko::Fonts::LED_8x16
canvas.font_scale = 2
canvas.text "Hello World!"

# Add some shapes.
canvas.rectangle(10, baseline, 56, -56)
canvas.circle(112, baseline -28, 28)
triangle_x = 146
canvas.triangle(triangle_x, baseline, triangle_x+56, baseline, triangle_x+28, baseline-56)

# 1px border, inset 2px from screen edges
canvas.rectangle  2, 2, canvas.columns-5, canvas.rows-5

# Show it
epaper.draw
epaper.deep_sleep
board.finish_write
