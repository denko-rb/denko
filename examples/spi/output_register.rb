#
# Example of LED connected through an output shift register (74HC595).
# Can be used over either a bit bang or hardware SPI interface.
#
require 'bundler/setup'
require 'denko'

# SPI pins (on board)
SPI_BIT_BANG_PINS   = { clock: 13, output: 11 }
REGISTER_SELECT_PIN = 10

# LED pin (on register parallel outputs)
LED_PIN = 0

# Works on hardware or bit-bang SPI.
board = Denko::Board.new(Denko::Connection::Serial.new)
# bus = Denko::SPI::Bus.new(board: board)
bus = Denko::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)

# OutputRegister needs a bus and its select pin.
# Other options and their defaults:
#     bytes:          1          - For daisy-chaining registers
#     spi_frequency:  1000000    - Only affects hardware SPI interfaces
#     spi_mode:       0
#     spi_bit_order:  :msbfirst
#
register = Denko::SPI::OutputRegister.new(bus: bus, pin: REGISTER_SELECT_PIN)

# Turn the LED on by setting the corresponding register bit to 1, then writing to it.
register.bit_set(LED_PIN, 1)
register.write
sleep 2

# OutputRegister is a BoardProxy, so DigitalOutput components can use
# it in place of a board. Do that with the LED instead.
#
led = Denko::LED.new(board: register, pin: LED_PIN)

# Blink the LED and sleep the main thread.
led.blink 0.5
sleep
