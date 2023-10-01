#
# Example using AHT21 sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)
sensor = Denko::Sensor::AHT10.new(bus: bus) # address: 0x38 default

# Get the shared #print_tph_rading method to print readings neatly.
require_relative 'neat_tph_readings'

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
