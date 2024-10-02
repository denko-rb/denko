#
# D3231 real-time-clock over I2C. Set time and read back every 5 seconds.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
i2c   = Denko::I2C::Bus.new(board: board) # address: 0x68 default

# Tell the bus to search for devices.
i2c.search

if i2c.found_devices.empty?
  puts "No I2C devices connected!"
  return
end

# 0x68 is the I2C address for most real time clocks.
unless (i2c.found_devices.include? 0x68)
  puts "DS3231 real time clock not found!"
  return
end

puts "Using DS3231 RTC at address 0x68"; puts
rtc = Denko::RTC::DS3231.new(bus: i2c, address: 0x68)
rtc.time = Time.now

5.times do
  puts rtc.time
  sleep 5
end
