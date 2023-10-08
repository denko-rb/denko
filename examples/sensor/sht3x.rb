#
# Example using SHT30/31/35 sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)
sensor = Denko::Sensor::SHT3X.new(bus: bus)

# Heater control
sensor.heater_on
puts "Heater on: #{sensor.heater_on?}"
sensor.heater_off
puts "Heater off: #{sensor.heater_off?}"

# Reset (turns heater off)
sensor.reset
puts "Resetting..."
puts "Heater off: #{sensor.heater_off?}"
puts

# Set repeatability= :low, :medium or :high (default). See datasheet for details.
sensor.repeatability = :high

# Get the shared #print_tph_reading method to print readings neatly.
require_relative 'neat_tph_readings'

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
