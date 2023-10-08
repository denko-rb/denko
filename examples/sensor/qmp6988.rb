#
# Example using QMP6988 sensor over I2C, for air temperature and pressure.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)
sensor = Denko::Sensor::QMP6988.new(bus: bus) # address: 0x70 default

# Verify chip_id.
print "I2C device has chip ID: 0x#{sensor.chip_id.to_s(16).upcase}. "
if sensor.chip_id == 0x5C
  puts "This matches the QMP6988."
else
  puts "This does not match the QMP6988."
end
puts

#
# Change measurement settings:
#   temperature_samples can be 1,2,4,8,16,32 or 64 (default: 1)
#   pressure_samples    can be 1,2,4,8,16,32 or 64 (default: 1)
#   iir_coefficient     can be 0,2,4,8,16 or 32    (default: 0)
#
# High accuracy settings from datasheet, with IIR of 2.
sensor.temperature_samples = 2
sensor.pressure_samples = 16
sensor.iir_coefficient = 2

# Change mode (default: forced_mode)
# sensor.forced_mode
# sensor.continuous_mode

#
# Set standby time (between measurements) for continuous mode only:
#   standby_time (given in ms) can be 1,5,20,250,500,1000,2000 or 4000 (default: 1)
#
# sensor.standby_time = 500

# Get the shared #print_tph_reading method to print readings neatly.
require_relative 'neat_tph_readings'

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
