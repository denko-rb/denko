#
# KY-040 (30 detent) rotary encoder on a microcontroller, listener at 1ms.
#
# WARNING: This method is not precise and may miss steps. Don't use for anything
# that requires all steps to be read for exact positioning or high speed.
#
require 'bundler/setup'
require 'denko'

PIN_A = 4
PIN_B = 5

board = Denko::Board.new(Denko::Connection::Serial.new)

# Other options and their default values:
#
# divider: 1                 # read every divider milliseconds (Board only)
# debounce_time: 1           # software debounce in microseconds (PiBoard only)
# counts_per_revolution: 60  # for generic 30 detent rotary encoders
#
encoder = Denko::DigitalIO::RotaryEncoder.new board: board,
                                              pins:  { a: PIN_A, b: PIN_B }

# Reverse direction.
# encoder.reverse

# Reset count and angle to 0.
# encoder.reset

encoder.add_callback do |state|
  change_printable = state[:change].to_s
  change_printable = "+#{change_printable}" if state[:change] > 0
  puts "Encoder Change: #{change_printable} | Count: #{state[:count]} | Angle: #{state[:angle]}\xC2\xB0"
end

sleep
