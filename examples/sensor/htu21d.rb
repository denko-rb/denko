#
# HTU21D sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'
require_relative 'neat_tph_readings'

board  = Denko::Board.new(Denko::Connection::Serial.new)
bus    = Denko::I2C::Bus.new(board: board)
htu21d = Denko::Sensor::HTU21D.new(bus: bus) # address: 0x40 default

# Get and set heater state.
htu21d.heater_on
puts "Heater on: #{htu21d.heater_on?}"
htu21d.heater_off
puts "Heater off: #{htu21d.heater_off?}"
puts

# Back to default settings, except heater state.
htu21d.reset

# Only 4 resolution combinations are available, and need to be
# set by giving a bitmask from the datasheet:
#   0x00 = 14-bit temperature, 12-bit humidity
#   0x01 = 12-bit temperature,  8-bit humidity (default)
#   0x80 = 13-bit temperature, 10-bit humidity
#   0x81 = 11-bit temperature, 11-bit humidity
#
htu21d.resolution = 0x81
puts "Temperature resolution: #{htu21d.resolution[:temperature]} bits"
puts "Humidity resolution:    #{htu21d.resolution[:humidity]} bits"
puts

htu21d.read
puts "Temperature unit helpers: #{htu21d.temperature} \xC2\xB0C | #{htu21d.temperature_f} \xC2\xB0F | #{htu21d.temperature_k} K"
puts

# Poll it and print readings.
htu21d.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
