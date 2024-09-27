#
# Example using a BME280 sensor over I2C, for temperature, pressure and humidity.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board)

sensor = Denko::Sensor::BME280.new(bus: bus) # address: 0x76 default
# Use A BMP280 with no humidity instead.
# sensor = Denko::Sensor::BMP280.new(bus: bus) # address: 0x76 default

# Default reading mode is oneshot ("forced" in datasheet).
# sensor.oneshot_mode

# Enable oversampling independently on each sensor.
# sensor.temperature_samples = 8
# sensor.pressure_samples = 2
# sensor.humidity_samples = 4

# Enable continuous reading mode ("normal" in datasheet), with standby time and IIR filter.
# sensor.continuous_mode
# sensor.standby_time = 62.5
# sensor.iir_coefficient = 4

# Print raw config register bits.
# print sensor.config_register_bits

# Get the shared #print_tph_reading method to print readings neatly.
require_relative 'neat_tph_readings'

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
