#
# Example of reading a JSN-SR04T ultrasonic sensor, in mode 2.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
uart = Denko::UART::Hardware.new(board: board, index: 1, baud: 9600)
ultrasonic = Denko::Sensor::JSNSR04T.new(board: board, uart: uart)

ultrasonic.poll(1) do |distance|
  puts "Distance: #{distance} mm"
end

sleep
