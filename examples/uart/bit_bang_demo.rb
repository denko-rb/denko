#
# Bit-bang UART is only used on the Arduino UNO / ATmega328p, because it has no
# extra hardware UARTs. This also makes a self-loopback test impossible. Connect a
# second board (Arduino Mega) and use its UART1 to verify bit-bang works on the Uno.
#
require 'bundler/setup'
require 'denko'

uno  = Denko::Board.new(Denko::Connection::Serial.new(device: "/dev/cu.usbserial-1450"))
mega = Denko::Board.new(Denko::Connection::Serial.new(device: "/dev/cu.usbmodem14101"))

mega_uart1  = Denko::UART::Hardware.new(board: mega, index: 1, baud: 31250)
uno_bb_uart = Denko::UART::BitBang.new(board: uno, pins: { rx:10, tx:11 }, baud: 31250)

# Write to Uno, read from Mega
uno_bb_uart.write("Hello World!\n")
sleep 0.5
line = mega_uart1.gets
puts "Mega received from Uno: #{line}"

# Write to Uno, read from Mega
mega_uart1.write("Goodbye World!\n")
sleep 0.5
line = uno_bb_uart.gets
puts "Uno received from Mega: #{line}"
