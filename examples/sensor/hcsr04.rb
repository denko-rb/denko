#
# Example of reading an HC-SR04 ultrasonic sensor.
#
require 'bundler/setup'
require 'denko'

TRIGGER_PIN = 6
ECHO_PIN    = 7

board = Denko::Board.new(Denko::Connection::Serial.new)
hcsr04 = Denko::Sensor::HCSR04.new(board: board, pins: {trigger: TRIGGER_PIN, echo: ECHO_PIN})

hcsr04.poll(0.50) do |distance|
  puts "Distance: #{distance} mm"
end

sleep
