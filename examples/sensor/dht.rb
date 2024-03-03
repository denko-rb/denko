#
# Example of how to use the DHT class for DHT 11 and DHT 22 sensors.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
sensor = Denko::Sensor::DHT.new(pin: 5, board: board)

# Get the shared #print_tph_reading method to print readings neatly.
require_relative 'neat_tph_readings'

sensor.read
puts "Temperature unit helpers: #{sensor.temperature} \xC2\xB0C | #{sensor.temperature_f} \xC2\xB0F | #{sensor.temperature_k} K"
puts

# Don't try to read it again too quickly.
sleep(1)

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
