#
# Font usage example on 128x64 SSD1306 OLED over I2C.
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

y = 10
canvas.text_cursor = [1,y]
canvas.font = Denko::Fonts::LED_5x7
canvas.print("LED_5x7")

y += 10
canvas.text_cursor = [0,y]
canvas.font = Denko::Fonts::LED_6x8
canvas.print("LED_6x8 (Default)")

y += 18
canvas.text_cursor = [1,y]
canvas.font = Denko::Fonts::LED_8x16
canvas.print("LED_8x16")

y += 20
canvas.text_cursor = [0,y]
canvas.font = Denko::Fonts::LED_6x8
canvas.font_scale = 2
canvas.print("LED_6x8")

canvas.font_scale = 1
canvas.text_cursor = [86,y-8]
canvas.print(" (2x) ")
canvas.text_cursor = [84,y]
canvas.print(" scale ")

oled.draw
board.finish_write

# Digit only fonts also included:
# Denko::Fonts::COURIER_NEW_DIGITS_11x17
# Denko::Fonts::COMIC_SANS_DIGITS_24x32 