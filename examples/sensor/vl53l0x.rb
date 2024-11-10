#
# VL53L0X sensor over I2C to measure distance.
#
require 'bundler/setup'
require 'denko'

board  = Denko::Board.new(Denko::Connection::Serial.new)
bus    = Denko::I2C::Bus.new(board: board)
sensor = Denko::Sensor::VL53L0X.new(bus: bus) # address: 0x29 default

# Correct for my sensor always being off by +52mm.
# Adjust this as needed to suit yours.
sensor.correction_offset = -52

sensor.poll(0.2) do |distance|
  puts "Distance: #{distance} mm"
end

sleep
