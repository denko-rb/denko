#
# Example showing how to load, modify and save the board's EEPROM.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# Initialization automatically gets all EEPROM data from the board.
# eeprom = Denko::EEPROM::BuiltIn(board: board)
eeprom = board.eeprom

# EEPROM size reported by the board.
puts "EEPROM Size: #{eeprom.length} bytes"

# Write a byte to a single address.
address1 = 323
eeprom[address1] = 127

# Read it back.
print "EEPROM address #{address1} contains "
puts eeprom[address1]

# Write an entire array, giving only the start address.
address2 = 444
data = [1, 2, 3, 4, 5, 6]
eeprom[address2] = data

# Read it back like reading a range of a regular Array.
address3 = address2 + data.length - 1
print "EEPROM range (#{address2}..#{address3}) contains "
puts eeprom[address2..address3].inspect

board.finish_write
