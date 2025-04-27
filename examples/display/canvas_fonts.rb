#
# Example showing how to use fonts on pixel displays.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# Using SSD1306 OLED (128x64), connected over I2C. Change as needed.
bus = Denko::I2C::Bus.new(board: board)
display = Denko::Display::SSD1306.new(bus: bus, rotate: true) # address: 0x3C is default

canvas = display.canvas

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

display.draw
board.finish_write

# Digit only fonts also included:
# Denko::Fonts::COURIER_NEW_DIGITS_11x17
# Denko::Fonts::COMIC_SANS_DIGITS_24x32
