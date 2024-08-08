#
# Example of a simple rotary encoder polling at ~1ms.
#
# WARNING: This method is not precise at all. Please do not use it for anything
# that requires all steps to be read for precise positioning or high speed.
#
require 'bundler/setup'
require 'denko'

PIN_A = 4
PIN_B = 5

board = Denko::Board.new(Denko::Connection::Serial.new)
encoder = Denko::DigitalIO::RotaryEncoder.new board: board,
                                              pins: { a: PIN_A, b: PIN_B },
                                              divider: 1,                 # Default. Applies only to Board. Read pin every 1ms.
                                              debounce_time: 1,           # Default. Applies only to PiBoard. Debounce filter set to 1 microsecond.
                                              counts_per_revolution: 60   # Default

# Reverse direction if needed.
encoder.reverse

# Reset angle and count to 0.
encoder.reset

encoder.add_callback do |state|
  change_printable = state[:change].to_s
  change_printable = "+#{change_printable}" if state[:change] > 0

  puts "Encoder Change: #{change_printable} | Count: #{state[:count]} | Angle: #{state[:angle]}\xC2\xB0"
end

sleep
