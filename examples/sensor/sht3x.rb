#
# SHT30/31/35 sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'
require_relative 'neat_tph_readings'

board  = Denko::Board.new(Denko::Connection::Serial.new)
bus    = Denko::I2C::Bus.new(board: board)
sensor = Denko::Sensor::SHT3X.new(bus: bus) # address: 0x44 default

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

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
