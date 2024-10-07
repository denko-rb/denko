#
# Example using one board's UART as the transport for a second board, also running Denko.
#
# For this example, board1 (direct) is an Arduino Mega. board2 (passthrough) is an Uno,
# running Denko, with its UART pins (0, 1) connected to the Mega's UART1 pins (18, 19)
#
# This isn't 100% reliable. The Rx buffer on the direct board is periodically read, instead
# of using an interrupt. It can potentially overflow, causing data from the passthrough board
# to be lost. If flow control data is lost, the connection will halt.
#
# Use at your own risk, but for the best possible performance:
#  1) Avoid long running commands on the direct board (eg. IR output, WS2812 etc.).
#     These block the CPU enough that the Rx buffer may not be read in time to avoid overflow.
#  2) Use the lowest practical baud rate on the passthrough board, so the direct board's Rx
#     buffer takes as long as possible to fill, reducing the chance of data loss.
#
require 'bundler/setup'
require 'denko'

board1 = Denko::Board.new(Denko::Connection::Serial.new)

uart   = Denko::UART::Hardware.new(board: board1, index: 1)
board2 = Denko::Board.new(Denko::Connection::BoardUART.new(uart, baud: 115200))

led1 = Denko::LED.new(board: board1, pin: 13)
led1.blink(0.5)

led2 = Denko::LED.new(board: board2, pin: 13)
led2.blink(0.5)

input = Denko::AnalogIO::Input.new(board: board2, pin: :A0)
input.smoothing = true
input.smoothing_size = 10
# Show input value only if it differs from previous state.
input.add_callback do |value|
  puts "A0 value: #{value}" if value != input.state
end
input.listen(16)

sleep
