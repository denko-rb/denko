#
# Simple button example.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
button = Denko::DigitalIO::Button.new(board: board, pin: 5, pullup: true)

button.up   { puts "Button released!" } 
button.down { puts "Button pressed!" }

sleep
