#
# Example showing how to transform the Canvas on pixel displays.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# Using SSD1306 OLED (128x64), connected over I2C. Change as needed.
bus = Denko::I2C::Bus.new(board: board)
display = Denko::Display::SSD1306.new(bus: bus, rotate: true) # address: 0x3C is default

# NOTE: Canvas transforms are independent of any transforms that can be configured
# on the display itself. Those will perform better and should be used if you simply
# need to reflect or rotate the entire display always.
canvas = display.canvas

# Very useful reflected text...
canvas.reflect(:x)
canvas.text_cursor = [32, 32]
canvas.print("Relfected!")

# Cancels out #reflex(:x) above, returning to the original coordinates.
canvas.reflect(:x)
canvas.text_cursor = [0,8]
canvas.print("0 DEG")

# Canvas always rotates around its center, and 0,0 is always the new top-left corner.
canvas.rotate(90)
canvas.text_cursor = [0,8]
canvas.print("90 DEG")

# Transforms are cumulative, but do not affect anything previously drawn.
canvas.rotate(90)
canvas.text_cursor = [0,8]
canvas.print("180 DEG")

canvas.rotate(90)
canvas.text_cursor = [0,8]
canvas.print("270 DEG")

# Send the canvas to the OLED's graphics RAM so it shows.
display.draw
board.finish_write
