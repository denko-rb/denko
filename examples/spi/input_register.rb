#
# Button connected through input shift register (CD4021B).
#
require 'bundler/setup'
require 'denko'

# SPI pins (on board)
SPI_BIT_BANG_PINS   = { clock: 13, input: 12 }
REGISTER_SELECT_PIN = 9

# Button pin (on register parallel outputs)
BUTTON_PIN = 0

board = Denko::Board.new(Denko::Connection::Serial.new)
bus   = Denko::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)

# InputRegister needs a bus and its select pin. The CD4021 likes SPI mode 2.
# Other options and their defaults:
#     bytes:          1          - For daisy-chaining registers
#     spi_frequency:  1000000    - Only affects hardware SPI interfaces
#     spi_mode:       0
#     spi_bit_order:  :msbfirst
#
register = Denko::SPI::InputRegister.new(bus: bus, pin: REGISTER_SELECT_PIN, spi_mode: 2)

# InputRegister is a BoardProxy, so DigitalInput components can can use
# it in place of a board. Use it with a Button instance.
#
# button starts listening automatically, which tells register to start listening.
# On Denko::Board, InputRegisters listen with an 8ms interval by default, compared
# to 1ms default for a Button directly connected to a Board.
#
button = Denko::DigitalIO::Button.new(pin: BUTTON_PIN, board: register)

# Button callbacks.
button.down { puts "Button pressed"  }
button.up   { puts "Button released" }

# Keep main thread alive.
sleep
