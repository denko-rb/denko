#
# HDC1080 sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'
require_relative 'neat_tph_readings'

board  = Denko::Board.new(Denko::Connection::Serial.new)
bus    = Denko::I2C::Bus.new(board: board)
sensor = Denko::Sensor::HDC1080.new(bus: bus) # address: 0x40 default

# Show the serial number.
puts "Serial number: 0x#{sensor.serial_number.to_s(16)}"

# Other info methods:
# sensor.device_info
# sensor.manufacturer_id
# sensor.device_id

# This is true if VCC supplied to the sensor is < 2.8V.
# sensor.battery_low?

# Get and set heater state.
sensor.heater_on
puts "Heater on: #{sensor.heater_on?}"
sensor.heater_off
puts "Heater off: #{sensor.heater_off?}"
puts

# Back to default settings, except heater state.
sensor.reset

# Configure temperature and humidity reading resolutions
sensor.temperature_resolution = 14  # valid are 14, 11
sensor.humidity_resolution = 14     # valid are 14, 11, 8
puts "Temperature resolution: #{sensor.temperature_resolution} bits"
puts "Humidity resolution:    #{sensor.humidity_resolution} bits"
puts

sensor.read
puts "Temperature unit helpers: #{sensor.temperature} \xC2\xB0C | #{sensor.temperature_f} \xC2\xB0F | #{sensor.temperature_k} K"
puts

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

=begin
# To avoid blocking for 200 ms on mruby:
sensor.add_callback do |reading|
  print_tph_reading(reading)
end

loop do
  sensor._start_conversion
  sleep 0.200 # Do something else in your main loop here
  sensor._read_values
  sleep 4.800
end
=end

sleep
