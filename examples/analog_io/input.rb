#
# This example shows how to use your board's analog-to-digital-converter(ADC) pins,
# through the AnalogIO::Input class. ADC inputs can be connected to sensors
# which produce a variable output voltage, such as light dependent resistors,
# or a simple temperature sensor like the TMP36.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
input = Denko::AnalogIO::Input.new(pin: :A0, board: board)

# Single read that blocks the main thread. When a value is received, the given
# code block runs only once, and then the main thread continues.
input.read { |value| puts "#{Time.now} Single read #1: #{value}" }

# Read (poll) the input every half second. This happens in a separate thread, 
# so sleep the main thread for a while to get some values.
# Given code block is added as a callback, and runs every time a value is received.
input.poll(0.5) { |value| puts "#{Time.now} Polling: #{value}" }
sleep 3

# Stop polling. Automatically removes the #poll callback.
input.stop

# Listening is similar to polling. The board reads the input and sends the value
# every time interval, except it's keeping time. We only send the initial command,
# not one for each read. Smaller intervals like 32 milliseconds are possible.
# Powers of 2 from 1 to 128 are supported for listener intervals.
input.listen(32) { |value| puts "#{Time.now} Listening: #{value}" }
sleep 0.5

# Stop listening. Automatically removes the #listen callback.
input.stop

# This adds a persistent callback, which runs no matter how a read happens.
# It will not be removed by #stop.
input.on_data { |value| puts "#{Time.now} Persistent callback: #{value}" }

# This is a persistent callback with a custom key.
input.on_data(:test) { |value| puts "#{Time.now} Keyed callback: #{value}"}

# If we do a single read, the two persistent callbacks, and the block given, should run once each.
input.read { |value| puts "#{Time.now} Single read #2: #{value}" }

# If we listen, the two persistent callbacks, and the block given should run many times.
input.listen(8) { |value| puts "#{Time.now } Listening again: #{value}" }
sleep 0.125
input.stop

# Remove callbacks keyed with :test.
input.remove_callbacks(:test)

# Remove all callbacks.
input.remove_callbacks
