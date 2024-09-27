#
# Example for a potentiometer.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
pot = Denko::AnalogIO::Potentiometer.new(pin: :A0, board: board)

pot.on_data do |reading|
  puts "Potentiometer reading: #{reading}" if reading != pot.state
end

sleep
