#
# This is an example of how to use the servo class
#
require 'bundler/setup'
require 'denko'

PIN   = 9

board = Denko::Board.new(Denko::Connection::Serial.new)
servo = Denko::Motor::Servo.new(board: board, pin: PIN)

# Add different angles (in degrees) to the array below to try out your servo.
# Note: Some servos may not have a full 180 degree sweep.
[0, 90, 180, 90].cycle do |angle|
  servo.position = angle
  sleep 0.5
end
