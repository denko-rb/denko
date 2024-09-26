#
# Example using a BMP180 sensor over I2C, for temperature and pressure.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board)
sensor = Denko::Sensor::BMP180.new(bus: bus) # address: 0x77 default

# Enable oversampling for the pressure sensor only (1,2,4, 8).
# sensor.pressure_samples = 8

# Demonstrate helper methods
result = sensor.read
puts "Temperature unit helpers: #{sensor.temperature} \xC2\xB0C | #{sensor.temperature_f} \xC2\xB0F | #{sensor.temperature_k} K"
puts "Pressure unit helpers: #{sensor.pressure} Pa | #{sensor.pressure_atm.round(6)} atm | #{sensor.pressure_bar.round(6)} bar"
puts

# Get the shared #print_tph_reading method to print readings neatly.
require_relative 'neat_tph_readings'

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
