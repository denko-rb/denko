#
# SevenSegment LED driven though a pair of daisy chained OutputRegisters
# (74HC595), with some segments on each register.
#
require 'bundler/setup'
require 'denko'

# SPI pins (on board)
SPI_BIT_BANG_PINS   = { clock: 13, output: 11 }
REGISTER_SELECT_PIN = 10

# SevenSegment pins (on registers' parallel outputs)
SEVEN_SEGMENT_PINS = { cathode: 14, a: 10, b: 9, c: 4, d: 2, e: 1, f: 12, g: 13 }

board = Denko::Board.new(Denko::Connection::Serial.new)
bus   = Denko::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)

# Model as one 2-byte (16-bit) OutputRegister, since they're daisy chained.
# Bit numbering starts at the first register, so bit 0 of the second register
# is bit 8 of the OutputRegister instance.
register = Denko::SPI::OutputRegister.new(bus: bus, pin: REGISTER_SELECT_PIN, bytes: 2)
ssd      = Denko::LED::SevenSegment.new(board: register, pins: SEVEN_SEGMENT_PINS)

# Turn off the ssd on exit.
trap("SIGINT") { exit !ssd.off }

# Type a character and press Enter to show it on the SevenSegment LED.
loop { ssd.display(gets.chomp) }
