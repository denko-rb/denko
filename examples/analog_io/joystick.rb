#
# Use a generic 2-axis (double potentiometer) joystick.
#
require 'bundler/setup'
require 'denko'

X_PIN = :A1
Y_PIN = :A2

board = Denko::Board.new(Denko::Connection::Serial.new)
joystick = Denko::AnalogIO::Joystick.new  board: board,
                                          pins: {x: X_PIN, y: Y_PIN},
                                          invert_x: true,
                                          invert_y: true,
                                          # maxzone: 98,   # as percentage
                                          deadzone: 2      # as percentage

# Listen to both analog inputs at 250 Hz.
# joystick.listen(4)

# Simple 60Hz game loop.
loop do
  last_tick = Time.now

  # If listening, joystick.state is constantly updated in the background.
  # Otherwise, #read must be called each tick to update it.
  joystick.read
  puts joystick.state.inspect

  sleep(0.0001) while (Time.now - last_tick < 0.0166)
end
