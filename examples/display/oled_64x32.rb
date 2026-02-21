#
# Generic example for 64x32 OLEDs.
# Only seen in one I2C models (0.49") using the SSD1306 driver.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board)
oled = Denko::Display::SSD1306.new(bus: bus, width: 64, height: 32) # address: 0x3C is default

# Draw some text on the OLED's canvas (a Ruby memory buffer).
canvas = oled.canvas
baseline = 20
canvas.font = :bmp_5x7
canvas.text_cursor = 4, baseline+9
canvas.text "Hello World"

# Add some shapes to the canvas.
canvas.rectangle  x: 4,   y: baseline,    w: 16, h: -16
canvas.circle     x: 32,  y: baseline-8,  r: 8
canvas.triangle   x1: 44, y1: baseline,
                  x2: 60, y2: baseline,
                  x3: 52, y3: baseline-16

# 1px border to test screen edges.
canvas.rectangle x1: 0, y1: 0, x2: canvas.x_max, y2: canvas.y_max

# Send the canvas to the OLED's graphics RAM so it shows.
oled.draw
board.finish_write
