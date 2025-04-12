#
# AHT10, AHT15, AHT20, AHT21, AHT25 and AHT30 sensors over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'
require_relative 'neat_tph_readings'

board  = Denko::Board.new(Denko::Connection::Serial.new)
bus    = Denko::I2C::Bus.new(board: board)
# sensor = Denko::Sensor::AHT1X.new(bus: bus) # address: 0x38 default
# sensor = Denko::Sensor::AHT2X.new(bus: bus) # address: 0x38 default
sensor = Denko::Sensor::AHT3X.new(bus: bus) # address: 0x38 default

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
