#
# DHT sensor class for DHT 11 and DHT 22 sensors.
#
require 'bundler/setup'
require 'denko'
require_relative 'neat_tph_readings'

PIN    = 5

board  = Denko::Board.new(Denko::Connection::Serial.new)
sensor = Denko::Sensor::DHT.new(board: board, pin: PIN)

sensor.read
if sensor.temperature
  puts "Temperature unit helpers: #{sensor.temperature} \xC2\xB0C | #{sensor.temperature_f} \xC2\xB0F | #{sensor.temperature_k} K"; puts
else
  puts "ERROR: Sensor not connected... Quitting..."
  return
end

# Don't try to read it again too quickly.
sleep(1)

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
