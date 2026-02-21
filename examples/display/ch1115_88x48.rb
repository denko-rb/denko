#
# Example for 88x48 I2C OLED (0.5"), using CH1115 driver.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board)
oled = Denko::Display::CH1115.new(bus: bus, width: 88, height: 48) # address: 0x3C is default

# Draw some text on the OLED's canvas (a Ruby memory buffer).
canvas = oled.canvas
baseline = 32
canvas.text_cursor = 8, baseline+12
canvas.text "Hello World!"

# Add some shapes to the canvas.
canvas.rectangle  x: 6,   y: baseline,    w: 24, h: -24
canvas.circle     x: 46,  y: baseline-12, r: 12
canvas.triangle   x1: 58, y1: baseline,
                  x2: 82, y2: baseline,
                  x3: 70, y3: baseline-24

# 1px border to test screen edges.
canvas.rectangle x1: 0, y1: 0, x2: canvas.x_max, y2: canvas.y_max

# Send the canvas to the OLED's graphics RAM so it shows.
oled.draw
board.finish_write
