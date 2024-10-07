#
# Drive a DC motor with the L298 H-Bridge driver.
#
require 'bundler/setup'
require 'denko'
board = Denko::Board.new(Denko::Connection::Serial.new)

PINS = { direction1: 8, direction2: 9, enable: 10 }

# This is only 1 channel of the driver. Make a new object for each channel.
motor = Denko::Motor::L298.new(board: board, pins: PINS)

# Off without braking (initial state).
# motor.off
# motor.idle

# Go forward at half speed for a while.
motor.forward(50)
sleep 2

# Change direction.
motor.reverse(50)
sleep 2

# Speed up without changing direction.
motor.speed = 100
sleep 2

# Brake to stop quickly.
motor.brake
sleep 1

# Change from brake to forward, but 0 speed.
motor.forward(0)
sleep 1

# Speed up in 5% increments.
(1..20).each do |step|
  sleep 0.5
  motor.speed = step * 5
end

# Turn it off.
motor.off
board.finish_write
