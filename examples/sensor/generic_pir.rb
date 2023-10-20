#
# Example using a PIR motion sensor. Tested with AS312 and HC-SR501 sensors.
#
# General notes:
#   - Both sensors have a few seconds "dead time" after "motion stop" (logical 0), where further
#     motion will not trigger "motion start" (logical 1).
#
# HC-SR501 notes:
#   - Needs some time to warm up and start working properly.
#   - Set the time potentiometer to its lowest value.
#   - Make sure retriggering is enabled. It might be default, but there's a jumper to solder too.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
sensor = Denko::Sensor::GenericPIR.new(board: board, pin: 8)

sensor.on_motion_start { print "Motion detected!      \r" }
sensor.on_motion_stop  { print "No motion detected... \r" }

# Read initial state.
sensor.read

sleep
