#
# AT24C256 EEPROM example
#
require 'bundler/setup'
require 'denko'

board  = Denko::Board.new(Denko::Connection::Serial.new)
i2c    = Denko::I2C::Bus.new(board: board)
eeprom = Denko::EEPROM::AT24C.new(bus: i2c)

# Addresses for the 256kib version are 0..32767. Each address holds 1 byte.

# Write a byte to a single address.
address1 = 323
eeprom[address1] = 127

# Read it back.
print "EEPROM address #{address1} contains "
puts eeprom[address1]

# Write an entire array, giving only the start address.
address2 = 555
data = [1, 2, 3, 4, 5, 6]
eeprom[address2] = data

# Read it back like reading a range of a regular Array.
address3 = address2 + data.length - 1
print "EEPROM range (#{address2}..#{address3}) contains "
puts eeprom[address2..address3].inspect

board.finish_write
