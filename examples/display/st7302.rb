#
# Example using the reflective ST7302 reflective LCD over SPI.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::Bus.new(board: board)

# Must be connected to SPI bus CLK and MOSI pins, plus select, dc and reset.
lcd = Denko::Display::ST7302.new(bus: bus, pins: { select: 10, dc: 9, reset: 8 })
canvas = lcd.canvas

# Draw some text on the canvas (a Ruby memory buffer).
baseline = 75
canvas.text_cursor = 32,baseline+35
canvas.font = :bmp_8x16
canvas.font_scale = 2
canvas.text "Hello World!"

# Add some shapes.
canvas.rectangle x: 20,   y: baseline,    w: 60, h: -60
canvas.circle    x: 125,  y: baseline-30, r: 30
tri_x = 170
canvas.triangle x1: tri_x,    y1: baseline,
                x2: tri_x+60, y2: baseline,
                x3: tri_x+60, y3: baseline-60

# 1px border, inset 2px from screen edges
canvas.rectangle x1: 2, y1: 2, x2: canvas.x_max-2, y2: canvas.y_max-2

# Invert it or reset to normal
# lcd.invert_on
# lcd.invert_off

# Frame rate can be any of [0.25, 0,5, 1, 2, 4, 8, 16, 32]. Default is 8
# lcd.frame_rate = 4

# Show it
lcd.draw
board.finish_write
