#
# TSL2561 lgiht sensor.
#
require 'bundler/setup'
require 'denko'
require_relative 'neat_tph_readings'

board  = Denko::Board.new(Denko::Connection::Serial.new)
bus    = Denko::I2C::Bus.new(board: board)
sensor = Denko::Sensor::TSL2561.new(bus: bus) # address: 0x39 default

# Configurable integration time (poll with a grater interval than time used):
sensor.integration_time = 402
# sensor.integration_time = 101
# sensor.integration_time = 13.7

# Configurable gain
sensor.gain = 16
# sensor.gain = 1

# Configurable package type. When set to :cs, this slightly changes the calculation used
# to convert ADC values to lux. All other values behave the same. See datasheet for more info.
sensor.package_type = :tn
# sensor.package_type = :cs

sensor.poll(1) do |value|
  puts "#{Time.now} Lux: #{value.round(2)}"
end

sleep
