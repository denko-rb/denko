#
# Use your board's analog-to-digital-converter(ADC) pins with AnalogIO::Input.
# ADC inputs can be connected to sensors that produce variable output voltage,
# such as light dependent resistors, or a temperature sensor like the TMP36.
#
require 'bundler/setup'
require 'denko'

PIN = :A0

board = Denko::Board.new(Denko::Connection::Serial.new)
input = Denko::AnalogIO::Input.new(pin: PIN, board: board)

# Single read. Blocks main thread during read, then runs given block with the value.
input.read { |value| puts "#{Time.now} Single read #1: #{value}" }

# Poll repeatedly does single reads, in a separate thread, with an interval in seconds.
# Given block is saved as a callback, and runs each time a value is received.
input.poll(0.5) { |value| puts "#{Time.now} Polling: #{value}" }

# Does not block main thread, so wait for some values.
sleep 3
# Stop polling, automatically removing callback from #poll.
input.stop

# "Listening" is where the Board keeps time, reading the ADC at a small interval
# and continuously sends values, until #stop is called.
# Powers of 2 from 1 to 128 (in milliseconds) are supported for listener intervals.
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

board.finish_write
