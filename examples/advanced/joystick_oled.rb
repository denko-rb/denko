#
# Move a square around an OLED screen with a Joystick.
#
require 'bundler/setup'
require 'denko'

# Joystick
X_PIN = :A1
Y_PIN = :A2
connection  = Denko::Connection::Serial.new
board       = Denko::Board.new(connection)
joystick    = Denko::AnalogIO::Joystick.new board: board,
                                            pins: {x: X_PIN, y: Y_PIN},
                                            invert_x: true,
                                            invert_y: false,
                                            deadzone: 2

# OLED
bus    = Denko::I2C::Bus.new(board: board)
oled   = Denko::Display::SSD1306.new(bus: bus, rotate: true) # address: 0x3C is default
canvas = oled.canvas

# Joystick sensitivity multipler
sensitivity = 0.05

# How big should the square be?
size = 8

# Max and starting position for square (top left anchor).
x_max = canvas.columns - size
y_max = canvas.rows - size
x = (canvas.columns / 2) - (size / 2).round
y = (canvas.rows    / 2) - (size / 2).round

# joystick updates its state every ~ 16ms in background thread.
joystick.listen(16)
sleep 0.001 until (joystick.state[:x] && joystick.state[:y])

# Loop monitoring
target_frame_time = 0.01666
first_draw        = true
fps_samples_start = Time.now
last_fps_show     = Time.now
frame_start       = Time.now
frame_count       = 0

# Main loop
loop do
  last_frame   = frame_start
  frame_start  = Time.now

  # Calculate and show FPS ~ every second.
  frame_count += 1
  if (frame_start - last_fps_show >= 1)
    fps = frame_count / (frame_start - fps_samples_start)
    fps_samples_start = frame_start
    frame_count = 0
    print "FPS: #{fps.round}\r"
  end

  # Scale joystick sensitivity inversely with actual framerate.
  input_scaler = (frame_start - last_frame) / target_frame_time

  # Store old position and calculate new position.
  old_x = x
  old_y = y
  x = (x + (joystick.state[:x] * sensitivity * input_scaler)).round
  y = (y + (joystick.state[:y] * sensitivity * input_scaler)).round
  x = 0 if x < 0
  x = x_max if x > x_max
  y = 0 if y < 0
  y = y_max if y > y_max

  # If position unchanged, don't even do anything.
  if (x != old_x) || (y != old_y) || first_draw
    first_draw = false

    # Draw new position on canvas.
    canvas.clear
    canvas.square x: x, y: y, size: size, filled: true

    # Ensure previous frame written to physical board before writing this one.
    sleep 0.0001 while connection.writing?

    # Use 2 partial draws instead of redrawing the whole frame, to be faster.
    # First erase old position, then draw new position.
    oled.draw(old_x, old_x+size-1, old_y, old_y+size-1)
    oled.draw(x, x+size-1, y, y+size-1)
  end

  sleep 0.0001 while (Time.now - frame_start < target_frame_time)
end
