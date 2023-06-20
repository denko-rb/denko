#
# This is an example of how to use the servo class
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
servo = Denko::Motor::Servo.new(pin: 9, board: board)

# Add different angles (in degrees) to the array below to try out your servo.
# Note: Some servos may not have a full 180 degree sweep.

[0, 90].cycle do |angle|
  servo.position = angle
  sleep 0.5
end
