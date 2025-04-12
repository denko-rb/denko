#
# Example using an SSD1306 driven OLED screen over I2C.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# The SSD1306 OLED connects to either an I2C or SPI bus, depending on the model you have.
# Bus setup exampels in order:
#   I2C Hardware
#   I2C Bit-Bang
#   SPI Hardware
#   SPI Bit-Bang
#
bus = Denko::I2C::Bus.new(board: board)
# bus = Denko::I2C::BitBang.new(board: board, pins: {scl: 4, sda: 5})
# bus = Denko::SPI::Bus.new(board: board)
# bus = Denko::SPI::BitBang.new(board: board, pins: {clock: 13, output: 11})

# I2C OLED, connected to I2C SDA and SCL.
oled = Denko::Display::SSD1306.new(bus: bus, rotate: true) # address: 0x3C is default
# oled = Denko::Display::SH1106.new(bus: bus,rotate: true) # address: 0x3C is default
# oled = Denko::Display::SH1107.new(bus: bus,rotate: false) # address: 0x3C is default

# SPI OLED, connected to SPI CLK and MOSI pins.
# select: and dc: pins must be given. reset is optional (can be pulled high instead).
# oled = Denko::Display::SSD1306.new(bus: bus, pins: { select: 10, dc: 7, reset: 8 }, rotate: true)
# oled = Denko::Display::SH1106.new(bus: bus, pins: { select: 10, dc: 7, reset: 8}, rotate: true)

canvas = oled.canvas
baseline = 39

# Draw some text on the OLED's canvas (a Ruby memory buffer).
canvas.text_cursor = [27,baseline+16]
canvas.print("Hello World!")

# Add some shapes to the canvas.
canvas.rectangle(10, baseline, 30, -30)
canvas.circle(66, baseline - 15, 15)
canvas.triangle(87, baseline, 117, baseline, 102, baseline - 30)

# 1px border to test screen edges.
canvas.rectangle(0, 0, oled.columns-1, oled.rows-1)

# Send the canvas to the OLED's graphics RAM so it shows.
oled.draw
board.finish_write
