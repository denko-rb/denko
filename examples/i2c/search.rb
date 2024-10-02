#
# Example that shows the default I2C bus pins, and addresses of any
# devices connected to the bus.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# If board has a map, show the pins to the user.
if board.map
  puts "Detected board: #{board.name}"
  sda = board.map[:SDA] || board.map[:SDA0]
  scl = board.map[:SCL] || board.map[:SCL0]
  puts "Using default I2C interface on pins #{sda} (SDA) and #{scl} (SCL)"
else
  puts "Pin map not available for this board. Using default interface, but SCL and SDA pins unknown"
end
puts

# Board's hardware I2C interface on predetermined pins.
bus = Denko::I2C::Bus.new(board: board)
# Bit-banged I2C on any pins.
# bus = Denko::I2C::BitBang.new(board: board, pins: {scl: 8, sda: 9})

bus.search

if bus.found_devices.empty?
  puts "No devices found on I2C bus"
else
  puts "I2C device addresses found:"
  bus.found_devices.each do |address|
    # Print as hexadecimal.
    puts "0x#{address.to_s(16).upcase}"
  end
end

puts
board.finish_write
