#
# Example using the SSD160 E-Paper over SPI.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::Bus.new(board: board)

# Must be connected to SPI bus CLK and MOSI pins, plus select, dc, reset and busy.
epaper = Denko::Display::SSD1681.new(bus: bus, pins: { select: 10, dc: 9, reset: 8 , busy: 7})
canvas = epaper.canvas

# Hardware features
# epaper.reflect_x
# epaper.invert_black

# Draw some text on the canvas (a Ruby memory buffer).
baseline = 110
canvas.text_cursor = [8,baseline+35]
canvas.font = Denko::Fonts::LED_8x16
canvas.font_scale = 2
canvas.text "Hello World!"

# Add some shapes.
canvas.rectangle(10, baseline, 50, -50)
canvas.circle(103, baseline -25, 25)
triangle_x = 140
canvas.triangle(triangle_x, baseline, triangle_x+50, baseline, triangle_x+25, baseline-50)

# 1px border to test screen edges.
canvas.rectangle(0, 0, canvas.columns-1, canvas.rows-1)

# Show it
epaper.draw
epaper.deep_sleep
board.finish_write
