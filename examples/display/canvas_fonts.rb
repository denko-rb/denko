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
canvas.font = :bmp_5x7
canvas.text "LED_5x7"

y += 10
canvas.text_cursor = [0,y]
canvas.font = :bmp_6x8
canvas.text "LED_6x8 (Default)"

y += 18
canvas.text_cursor = [1,y]
canvas.font = :bmp_8x16
canvas.text "LED_8x16"

y += 20
canvas.text_cursor = [0,y]
canvas.font = :bmp_6x8
canvas.font_scale = 2
canvas.text "LED_6x8"

canvas.font_scale = 1
canvas.text_cursor = [86,y-8]
canvas.text " (2x) "
canvas.text_cursor = [84,y]
canvas.text " scale "

display.draw
board.finish_write
