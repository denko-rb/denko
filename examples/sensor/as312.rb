#
# Example using AS312 PIR motion sensor.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
sensor = Denko::Sensor::AS312.new(board: board, pin: 8)

sensor.on_motion_start { print "Motion detected!     \r" }
sensor.on_motion_stop  { print "No motion detected...\r" }

# Trigger an initial read.
sensor.read

sleep
