#
# Echo last pressed keyboard key to a seven segment LED.
#
require 'bundler/setup'
require 'denko'

PINS  = { cathode: 10, a: 3, b: 4, c: 5, d: 6, e: 7, f: 8, g: 9 }

board = Denko::Board.new(Denko::Connection::Serial.new)
ssd   = Denko::LED::SevenSegment.new board: board,
                                     pins:  PINS

# Turn off the ssd on exit
trap("SIGINT") { exit !ssd.off }

# Display each new line on the ssd
loop { ssd.display(gets.chomp) }
