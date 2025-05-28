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
canvas.text_cursor = 8, baseline+35
canvas.font = :bmp_8x16
canvas.font_scale = 2
canvas.text "Hello World!"

# Add some shapes.
canvas.rectangle  x: 10,  y: baseline,    w: 50, h: -50
canvas.circle     x: 103, y: baseline-25, r: 25
tri_x = 140
canvas.triangle x1: tri_x,    y1: baseline,
                x2: tri_x+50, y2: baseline,
                x3: tri_x+25, y3: baseline-50

# 1px border to test screen edges.
canvas.rectangle x1: 0, y1: 0, x2: canvas.x_max, y2: canvas.y_max

# Show it
epaper.draw
epaper.deep_sleep
board.finish_write
