#
# Use Relays to work with higher voltage circuits. This example
# closes and opens a relay to send a 500ms pulse on a 12V control circuit.
#
require 'bundler/setup'
require 'denko'

PIN = 6

board = Denko::Board.new(Denko::Connection::Serial.new)
relay = Denko::DigitalIO::Relay.new(board: board, pin: PIN)

relay.close
sleep(0.500)
relay.open

board.finish_write
