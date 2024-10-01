#
# Simple button example.
#
require 'bundler/setup'
require 'denko'

PIN = 3

board = Denko::Board.new(Denko::Connection::Serial.new)
button = Denko::DigitalIO::Button.new board: board,
                                      pin:   PIN,
                                      mode:  :input_pullup

button.up   { puts "Button released at #{Time.now.strftime '%H:%M:%S'}" }
button.down { puts "Button pressed  at #{Time.now.strftime '%H:%M:%S'}" }

sleep
