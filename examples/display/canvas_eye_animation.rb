#
# Example animating eyes that look around, made from primitive shapes.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# Using SSD1306 OLED (128x64), connected over I2C. Change as needed.
bus = Denko::I2C::Bus.new(board: board)
display = Denko::Display::SSD1306.new(bus: bus, rotate: true) # address: 0x3C is default
canvas = display.canvas

# Eye position and size values.
center_y   = 31
center_x_l = 48
center_x_r = 78
width_o    = 10 # x2
height_o   = 15 # x2
width_i    = 3  # x2
height_i   = 5  # x2

# Preset offsets for moving the irises.
positions = [
  [0, 0],
  [5, 0],
  [5, 5],
  [0, 8],
  [-5, 5],
  [-5, 0],
  [-5, -5],
  [0, -8],
  [5, -5],
  [5, 0],
]

offset = positions[0]
last_offset = offset

loop do
  canvas.clear

  # Corneas
  canvas.ellipse x: center_x_l, y: center_y, a: width_o, b: height_o, filled: true
  canvas.ellipse x: center_x_r, y: center_y, a: width_o, b: height_o, filled: true

  # Irises
  canvas.ellipse x: center_x_l + offset[0], y: center_y + offset[1], a: width_i, b: height_i, filled: true, color: 0
  canvas.ellipse x: center_x_r + offset[0], y: center_y + offset[1], a: width_i, b: height_i, filled: true, color: 0

  # Speculars
  canvas.set_pixel x: center_x_l - 2 + offset[0], y: center_y - 2 + offset[1]
  canvas.set_pixel x: center_x_r - 2 + offset[0], y: center_y - 2 + offset[1]

  display.draw

  # Get a new random position to move the irises.
  last_offset = offset
  offset = positions.sample while (offset == last_offset)

  sleep 1
end
