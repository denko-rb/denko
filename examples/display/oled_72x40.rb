#
# Example for 72x40 I2C OLED (0.42"), using SSD1306 driver.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board)
oled = Denko::Display::SSD1306.new(bus: bus, width: 72, height: 40) # address: 0x3C is default

# Draw some text on the OLED's canvas (a Ruby memory buffer).
canvas = oled.canvas
baseline = 26
canvas.font = :bmp_5x7
canvas.text_cursor = 7, baseline+9
canvas.text "Hello World!"

# Add some shapes to the canvas.
canvas.rectangle  x: 4,   y: baseline,    w: 20, h: -20
canvas.circle     x: 37,  y: baseline-10, r: 10
canvas.triangle   x1: 48, y1: baseline,
                  x2: 68, y2: baseline,
                  x3: 58, y3: baseline-20

# 1px border to test screen edges.
canvas.rectangle x1: 0, y1: 0, x2: canvas.x_max, y2: canvas.y_max

# Send the canvas to the OLED's graphics RAM so it shows.
oled.draw
board.finish_write
