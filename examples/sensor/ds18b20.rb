#
# Example of how to use the Dallas DS18B20 temperature sensor.
#
require 'bundler/setup'
require 'denko'

PIN   = 4

board = Denko::Board.new(Denko::Connection::Serial.new)
bus   = Denko::OneWire::Bus.new(board: board, pin: PIN)

unless bus.device_present?
  puts "No devices present on bus... Quitting..."
  return
end

if bus.parasite_power
  puts "Parasite power detected..."; puts
end

# Search the bus and use results to set up DS18B20 instances.
bus.search
ds18b20s = []
bus.found_devices.each do |d|
  if d[:class] == Denko::Sensor::DS18B20
    ds18b20s << d[:class].new(bus: bus, address: d[:address])
  end
end

if ds18b20s.empty?
  puts "No DS18B20 sensors found on the bus... Quitting...";
else
  puts "Found DS18B20 sensors with these serials:"
  puts ds18b20s.map { |d| d.serial_number }
  puts
end

# Format a reading for printing on a line.
def print_reading(reading, sensor)
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  print "Serial(HEX): #{sensor.serial_number} | Res: #{sensor.resolution} bits | "

  if reading[:crc_error]
    puts "CRC check failed for this reading!"
  else
    fahrenheit = (reading[:temperature] * 1.8 + 32).round(1)
    puts "#{reading[:temperature]} \xC2\xB0C | #{fahrenheit} \xC2\xB0F"
  end
end

ds18b20s.each do |sensor|
  sensor.poll(5) do |reading|
    print_reading(reading, sensor)
  end
end

sleep
