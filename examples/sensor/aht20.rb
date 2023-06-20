#
# Example using AHT21 sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)
aht20 = Denko::Sensor::AHT20.new(bus: bus)

aht20.poll(2) do |reading|
  puts "Polled Reading: #{reading[:temperature].round(3)} \xC2\xB0C | #{reading[:humidity].round(3)} % RH"
end

sleep
