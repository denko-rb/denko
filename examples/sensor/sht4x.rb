#
# SHT40 sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'
require_relative 'neat_tph_readings'

board  = Denko::Board.new(Denko::Connection::Serial.new)
bus    = Denko::I2C::Bus.new(board: board)
sensor = Denko::Sensor::SHT4X.new(bus: bus) # address: 0x44 default

# Read and print the unique serial number
puts "Serial Number: Ox#{sensor.serial.to_s(16).upcase}" if sensor.serial
puts

# Set repeatability= :low, :medium or :high (default). See datasheet for details.
sensor.repeatability = :high

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
