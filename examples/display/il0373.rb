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
canvas.text_cursor = 14, baseline+34
canvas.font = :bmp_8x16
canvas.font_scale = 2
canvas.text "Hello World!"

# Add some shapes.
canvas.rectangle x: 10,   y: baseline,    w: 56, h: -56
canvas.circle    x: 112,  y: baseline-28, r: 28
tri_x = 146
canvas.triangle x1: tri_x,    y1: baseline,
                x2: tri_x+56, y2: baseline,
                x3: tri_x+28, y3: baseline-56

# 1px border, inset 2px from screen edges
canvas.rectangle x1: 2, y1: 2, x2: canvas.x_max-2, y2: canvas.y_max-2

# Show it
epaper.draw
epaper.deep_sleep
board.finish_write
