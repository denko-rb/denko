#
# Example using the SSD160 E-Paper over SPI.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::Bus.new(board: board)

# Must be connected to SPI bus CLK and MOSI pins, plus select, dc, reset and busy.
epaper = Denko::Display::SSD1680.new(bus: bus, pins: { select: 10, dc: 9, reset: 8 , busy: 7})
canvas = epaper.canvas

# Draw some text on the canvas (a Ruby memory buffer).21
baseline = 85
canvas.text_cursor = [56,baseline+35]
canvas.font = Denko::Fonts::LED_8x16
canvas.font_scale = 2
canvas.text "Hello World!"

# Add some shapes.
canvas.rectangle(20, baseline, 76, -76)
canvas.circle(148, baseline -38, 38)
triangle_x = 200
canvas.triangle(triangle_x, baseline, triangle_x+76, baseline, triangle_x+38, baseline-76)

# 1px border to test screen edges.
canvas.rectangle(0, 0, canvas.columns-1, canvas.rows-1)

# Show it
epaper.draw
board.finish_write
