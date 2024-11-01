#
# Move a square around an OLED screen with a Joystick.
#
require 'bundler/setup'
require 'denko'

# Joystick
X_PIN = :A1
Y_PIN = :A2
board = Denko::Board.new(Denko::Connection::Serial.new)
joystick = Denko::AnalogIO::Joystick.new  board: board,
                                          pins: {x: X_PIN, y: Y_PIN},
                                          invert_x: true,
                                          invert_y: false,
                                          deadzone: 2

# OLED
bus = Denko::I2C::Bus.new(board: board)
oled = Denko::Display::SSD1306.new(bus: bus, rotate: true) # address: 0x3C is default
canvas = oled.canvas

# Joystick sensitivity multipler
sensitivity = 0.04

# How big should the square be?
square_side = 6
raise "square side must be even" unless (square_side % 2 == 0)

# Start in the center and determine max coords
x = ((canvas.columns - square_side) / 2) - 1
y = ((canvas.rows - square_side) / 2) - 1
x_max = canvas.columns - 1 - square_side
y_max = canvas.rows - 1 - square_side

# Main loop
loop do
  last_tick = Time.now

  # Store old position and calculate new position
  old_x = x
  old_y = y
  joystick.read
  x = (x + (joystick.state[:x] * sensitivity)).round
  y = (y + (joystick.state[:y] * sensitivity)).round
  x = 0 if x < 0
  x = x_max if x > x_max
  y = 0 if y < 0
  y = y_max if y > y_max

  # Draw new position on canvas
  canvas.clear
  canvas.filled_rectangle(x, y, square_side, square_side)

  # Update the OLED using two partial draws (faster):
  # One to erease old position, one to draw new position
  oled.draw(old_x, old_x+square_side, old_y, old_y+square_side)
  oled.draw(x, x+square_side, y, y+square_side)

  sleep(0.0001) while (Time.now - last_tick < 0.0166)
end
