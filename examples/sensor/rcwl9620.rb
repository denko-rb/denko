#
# Example using an RCWL-9620 sensor over I2C to measure distance.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)
sensor = Denko::Sensor::RCWL9620.new(bus: bus) # address: 0x57 default

sensor.poll(1) do |distance|
  puts "Distance is #{distance} mm"
end

sleep
