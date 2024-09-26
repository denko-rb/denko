#
# Example using AHT10 sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# Board's hardware I2C interface on predetermined pins.
bus = Denko::I2C::Bus.new(board: board)
# Bit-banged I2C on any pins.
# bus = Denko::I2C::BitBang.new(board: board, pins: {scl: 8, sda: 9})

sensor = Denko::Sensor::AHT10.new(bus: bus) # address: 0x38 default

# Get the shared #print_tph_reading method to print readings neatly.
require_relative 'neat_tph_readings'

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
