#
# Example of a smiple rotary encoder polling at ~1ms.
#
# WARNING: This method is not precise at all. Please do not use it for anything
# that requires all steps to be read for precise positioning or high speed.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
encoder = Denko::DigitalIO::RotaryEncoder.new board: board,
                                              pins: { a: 4, b: 5 },
                                              divider: 1,                 # default, reads each pin every 1ms
                                              steps_per_revolution: 30    # default

# Reverse direction if needed.
# encoder.reverse

# Reset angle and steps to 0.
encoder.reset

encoder.add_callback do |state|
  puts "Encoder moved #{state[:change]} steps | CW step count: #{state[:steps]} | Current angle: #{state[:angle]}\xC2\xB0"
end

sleep
