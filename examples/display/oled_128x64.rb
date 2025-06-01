#
# Generic example for 128x64 OLEDs. This covers both I2C and SPI versions of
# SSD1306 and SH1106 at this pixel size.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# The OLED connects to either an I2C or SPI bus, depending on the model you have.
bus = Denko::I2C::Bus.new(board: board)
# bus = Denko::I2C::BitBang.new(board: board, pins: {scl: 4, sda: 5})
# bus = Denko::SPI::Bus.new(board: board)
# bus = Denko::SPI::BitBang.new(board: board, pins: {clock: 13, output: 11})

# I2C OLED, connected to I2C SDA and SCL.
oled = Denko::Display::SSD1306.new(bus: bus) # address: 0x3C is default
# oled = Denko::Display::SH1106.new(bus: bus,rotate: true) # address: 0x3C is default

# SPI OLED, connected to SPI CLK and MOSI pins.
# select: and dc: pins must be given. reset is optional (can be pulled high instead).
# oled = Denko::Display::SSD1306.new(bus: bus, pins: { select: 10, dc: 7, reset: 8 }, rotate: true)
# oled = Denko::Display::SH1106.new(bus: bus, pins: { select: 10, dc: 7, reset: 8}, rotate: true)

# Transformation features in hardware.
# oled.reflect_x
# oled.reflect_y
oled.rotate

# Draw some text on the OLED's canvas (a Ruby memory buffer).
canvas = oled.canvas
baseline = 42
canvas.text_cursor = 27, baseline+15
canvas.text "Hello World!"

# Add some shapes to the canvas.
canvas.rectangle  x: 10, y: baseline,    w: 30, h: -30
canvas.circle     x: 66, y: baseline-15, r: 15
canvas.triangle   x1: 87,   y1: baseline,
                  x2: 117,  y2: baseline,
                  x3: 102,  y3: baseline-30

# 1px border to test screen edges.
canvas.rectangle x1: 0, y1: 0, x2: canvas.x_max, y2: canvas.y_max

# Send the canvas to the OLED's graphics RAM so it shows.
oled.draw
board.finish_write
