#
# Test of the IROutput (infrared transmitter) class.
# The specific NEC code is one taken from the Arduino example:
# https://github.com/Arduino-IRremote/Arduino-IRremote/tree/master/examples/SendDemo
#
# To test your emitter works, flash the recieve sketch on a second board:
# https://github.com/Arduino-IRremote/Arduino-IRremote/tree/master/examples/ReceiveDemo
# Attach an IR receiver to the receive pin (2 for Atmel AVR) and observe its serial output.
#
# If you don't have 2 boards, use that sketch to capture a code from a remote.
# Copy the raw code (list of numbers in curly braces) and modify into a Ruby array.
# Put denko firmare back on your board, then test if the IR code operates your device.
#
# IR codes are also available from sites like:
# https://github.com/zmoteio/irdb.tk
# If formatted numbers with + and - prepended, you need to convert into a Ruby array first.
#
require 'bundler/setup'
require 'denko'

# Note: If testing with 2 boards on one computer, be explicit about which serial device
# runs denko. Use the second Serial.new call below and modify device: as needed.
# Monitor the receiver board in the Arduino (or some other) serial monitor.
#
connection = Denko::Connection::Serial.new
# connection = Denko::Connection::Serial.new(device: "/dev/ttyACM0")
board = Denko::Board.new(connection)

#
# Infrared can be used on most pins for most boards, but there might be conflicts
# with other hardware or libraries. Try different pins. For more info:
# https://github.com/Arduino-IRremote/Arduino-IRremote?#timer-and-pin-usage
#
ir = Denko::PulseIO::IROutput.new(board: board, pin: 4)

# NEC Raw-Data=0xF708FB04. LSBFIRST, so the binary for each hex digit below is backward.
code =  [ 9000, 4500,                                 # Start bit
          560, 560, 560, 560, 560, 1690, 560, 560,    # 0010 0x4 command
          560, 560, 560, 560, 560, 560, 560, 560,     # 0000 0x0 command
          560, 1690, 560, 1690, 560,560, 560, 1690,   # 1101 0xB command inverted
          560, 1690, 560, 1690, 560, 1690, 560, 1690, # 1111 0xF command inverted
          560, 560, 560, 560, 560, 560, 560, 1690,    # 0001 0x8 address
          560, 560, 560, 560, 560, 560, 560, 560,     # 0000 0x0 address
          560, 1690, 560, 1690, 560, 1690, 560, 560,  # 1110 0x7 address inverted
          560, 1690, 560, 1690, 560, 1690, 560, 1690, # 1111 0xF address inverted
          560]                                        # Stop bit

ir.write(code)
board.finish_write
