#
# Example using HTU31D sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)
sensor = Denko::Sensor::HTU31D.new(bus: bus)

# Get and set heater state.
sensor.heater_on
puts "Heater on: #{sensor.heater_on?}"
sensor.heater_off
puts "Heater off: #{sensor.heater_off?}"

# Back to default settings, including heater off, unlike HTU21D.
sensor.reset
puts "Resetting HTU31D..."
puts "Heater off: #{sensor.heater_off?}"
puts

# Resolution goes from 0..3 separately for temperature and humidity. See datasheet.
sensor.temperature_resolution = 3
sensor.humidity_resolution = 3

# Get the shared #print_tph_rading method to print readings neatly.
require_relative 'neat_tph_readings'

# Unlike HTU21D, HTU31D works as a regular polled sensor.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
