#
# Example of reading an HC-SR04 ultrasonic sensor.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
hcsr04 = Denko::Sensor::HCSR04.new(board: board, pins: {trigger: 6, echo: 7})

hcsr04.poll(0.05) do |distance|
  puts "Distance: #{distance} mm"
end

sleep
