#
# Example drawing paths (poly lines) and closed polygons on a Canvas
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# Using SSD1306 OLED (128x64), connected over I2C. Change as needed.
bus = Denko::I2C::Bus.new(board: board)
display = Denko::Display::SSD1306.new(bus: bus, rotate: true) # address: 0x3C is default
canvas = display.canvas

# Label
canvas.text_cursor = 7, canvas.y_max
canvas.text "Path & Polygon Demo"

# Draw a graph
canvas.path [
  [5,  32],
  [10, 32],
  [15, 28],
  [20, 40],
  [25, 30],
  [30, 10],
  [35, 16],
  [40, 28],
  [45, 25],
  [50, 25],
  [55, 23],
]

# Filled Octagon
canvas.polygon [
  [85,  40],
  [99,  40],
  [109, 30],
  [109, 16],
  [99,  6],
  [85,  6],
  [75,  16],
  [75,  30],
], filled: true

# Knockout text over it
canvas.text_cursor = 81, 26
canvas.text "STOP", color: 0

# Very inefficient knockout square over it
canvas.polygon [
  [90, 38],
  [93, 38],
  [93, 35],
  [90, 35],
], filled: true, color: 0

display.draw
board.finish_write
