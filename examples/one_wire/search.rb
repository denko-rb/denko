#
# Search a 1-Wire bus.
#
require 'bundler/setup'
require 'denko'

PIN   = 4

board = Denko::Board.new(Denko::Connection::Serial.new)
bus   = Denko::OneWire::Bus.new(board: board, pin: PIN)

# Call #device_present to reset the bus and return presence pulse as a boolean.
if bus.device_present?
  puts "Devices present on bus..."; puts
else
  puts "No devices present on bus... Quitting..."
  return
end

# The bus detects parasite power automatically when initialized.
# It can tell that parasite power is in use, but not by WHICH devices.
if bus.parasite_power
  puts "Parasite power detected..."; puts
end

# Calling #search finds connected devices and stores them in #found_devices.
# Each hash contains a device's ROM address and matching Ruby class if one exists.
bus.search
count = bus.found_devices.count
puts "Found #{count} device#{'s' if count > 1} on the bus:"

puts bus.found_devices.inspect
