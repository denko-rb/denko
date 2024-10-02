#
# This example combines the SHTX and QMP6988 examples. The M5Stack ENV III unit
# contains both sensors, accessible over a single I2C connection.
#
require 'bundler/setup'
require 'denko'
require_relative '../sensor/neat_tph_readings'

# How many degrees C the two temperature values can differ by before a warning.
TOLERANCE = 0.50

board = Denko::Board.new(Denko::Connection::Serial.new)
bus   = Denko::I2C::Bus.new(board: board)
sht   = Denko::Sensor::SHT3X.new(bus: bus)   # address: 0x44 default
qmp   = Denko::Sensor::QMP6988.new(bus: bus) # address: 0x70 default

# Configure for higher accuracy.
sht.repeatability       = :high
qmp.temperature_samples = 2
qmp.pressure_samples    = 16
qmp.iir_coefficient     = 2

# Buggy on ESP32-S3 in forced mode. Data registers return zeroes on all but first read.
# Can't recreate on ESP32 V1, AVR or SAMD21. Put it in contiuous mode just in case.
qmp.continuous_mode

loop do
  # Read both sensors.
  qmp_reading = qmp.read
  sht_reading = sht.read

  # Retry immediately if either failed.
  next unless (sht_reading && qmp_reading)

  # Warn if large gap between temperature readings.
  difference = (qmp_reading[:temperature] - sht_reading[:temperature]).abs
  if (difference > TOLERANCE)
    puts "WARNING: temperature values differed by more than #{TOLERANCE}\xC2\xB0C (#{difference.round(4)} \xC2\xB0C)"
  end

  # Combine values from both sensors, averaging their temperatures.
  average_temperature = (qmp_reading[:temperature] + sht_reading[:temperature]) / 2.0
  print_tph_reading(temperature: average_temperature, humidity: sht_reading[:humidity], pressure: qmp_reading[:pressure])

  sleep 5
end
