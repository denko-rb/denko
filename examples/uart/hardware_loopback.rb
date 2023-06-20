#
# Example that writes to TX pin of hardware UART1 and reads back on RX pin of same UART.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

uart = Denko::UART::Hardware.new(board: board, index: 1, baud: 31250)

uart.write("Hello World!\nBye World!\n")

sleep 1

puts uart.gets
puts uart.gets
