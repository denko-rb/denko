#
# 2 SPI registers (74HC595 and CD4021B) on the same bus, both acting as
# BoardProxies for their Subcomponents.
#
require 'bundler/setup'
require 'denko'

# SPI pins (on board)
SPI_BIT_BANG_PINS   = { clock: 13, input: 12, output: 11 }
OUT_REGISTER_SELECT = 10
IN_REGISTER_SELECT  = 9

# LED and Button pins (on their respective registers' parallel pins)
LED_PIN    = 0
BUTTON_PIN = 0

board        = Denko::Board.new(Denko::Connection::Serial.new)
bus          = Denko::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)
out_register = Denko::SPI::OutputRegister.new(bus: bus, pin: OUT_REGISTER_SELECT)
in_register  = Denko::SPI::InputRegister.new(bus: bus, pin: IN_REGISTER_SELECT, spi_mode: 2)

# LED connected to the output register.
led = Denko::LED.new(board: out_register, pin: LED_PIN)

# Button connected to the input register.
button = Denko::DigitalIO::Button.new(board: in_register, pin: BUTTON_PIN)

# Button callbacks.
button.down do
  led.on
  puts "Button pressed"
end

button.up do
  led.off
  puts "Button released"
end

# Keep main thread alive.
sleep
