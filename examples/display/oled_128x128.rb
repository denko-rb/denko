#
# Generic example for 128x128 OLEDs. This covers SH1107 for both I2C and SPI.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# The OLED connects to either an I2C or SPI bus, depending on the model you have.
bus = Denko::I2C::Bus.new(board: board)

# I2C OLED, connected to I2C SDA and SCL.
oled = Denko::Display::SH1107.new(bus: bus, rotate: false) # address: 0x3C is default

canvas = oled.canvas
baseline = 76

# Draw some text on the OLED's canvas (a Ruby memory buffer).
canvas.text_cursor = 27, baseline+15
canvas.text "Hello World!"

# Add some shapes to the canvas.
canvas.square   x: 10,  y: baseline-29, size: 30
canvas.circle   x: 66,  y: baseline-15, r: 15
canvas.triangle x1: 87,   y1: baseline,
                x2: 117,  y2: baseline,
                x3: 102,  y3: baseline-30

# 1px border to test screen edges.
canvas.rectangle x1: 0, y1: 0, x2: canvas.x_max, y2: canvas.y_max

# Send the canvas to the OLED's graphics RAM so it shows.
oled.draw
board.finish_write
