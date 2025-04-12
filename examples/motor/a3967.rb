#
# Use a stepper motor with the EasyDriver board: https://www.sparkfun.com/products/12779
#
require 'bundler/setup'
require 'denko'

PINS = { slp: 6, enable: 7, direction: 8, step: 10, ms1: 11, ms2: 12 }

board = Denko::Board.new(Denko::Connection::Serial.new)
stepper = Denko::Motor::A3967.new(board: board, pins: PINS)

# Default is 8 microsteps. Use 2 to move faster.
stepper.microsteps = 2

# 400 steps is now 1 revolution for a 200 step motor.
400.times do
  stepper.step_ccw
  sleep 0.002
end

# Sleep the driver and wait a while.
stepper.sleep
sleep 1

# Wake it up and set to full steps.
stepper.wake
stepper.microsteps = 1

#
# Now 200 steps the other way will return to the start.
# Longer sleep times to match bigger steps. Adjust for your motor.
#
200.times do
  stepper.step_cw
  sleep 0.006
end

# Sleep the driver once we're done.
stepper.sleep

# Writing to the board is done asynchronously.
# Make sure all commands are written before exit.
board.finish_write
