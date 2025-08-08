#
# ALS PT19 light sensor.
#
require 'bundler/setup'
require 'denko'

PIN = :A0
board = Denko::Board.new(Denko::Connection::Serial.new)
sensor = Denko::Sensor::ALSPT19.new(board: board, pin: PIN, vcc: 5.0)

# Enable smoothing on the input using the last 16 values.
sensor.smoothing = true
sensor.smoothing_size = 8

sensor.poll(0.5) do |value|
  puts "#{Time.now} Lux (approximate): #{value}"
end

sleep
