#
# Example using a D3231 real-time-clock over I2C. Sets the time and reads it
# back every 5 seconds.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
# Board's hardware I2C interface on predetermined pins.
bus = Denko::I2C::Bus.new(board: board) # address: 0x68 default

# Tell the bus to search for devices.
bus.search

# Show the found devices.
puts "No I2C devices connected!" if bus.found_devices.empty?
bus.found_devices.each do |address|
  puts "I2C device connected with address: 0x#{address.to_s(16)}"
end

# 0x68 or 140 is the I2C address for most real time clocks.
unless (bus.found_devices.include? 0x68)
  puts "No real time clock found!" unless bus.found_devices.empty?
else
  puts; puts "Using real time clock at address 0x68"; puts
  rtc = Denko::RTC::DS3231.new(bus: bus, address: 0x68)
  rtc.time = Time.now

  5.times do
    puts rtc.time
    sleep 5
  end
end
