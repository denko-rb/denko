require 'bundler/setup'
require 'denko'
#
# This example shows how to use denko when connecting to a board via TCP.
# This applies to the WiFi and Ethernet sketches, or serial sketch + ser2net.
# Port number defaults to 3466 (denko), but may be given as a second argument.
# It must correspond to the listening port set when the board was flashed.
#
connection = Denko::Connection::TCP.new("192.168.0.77", 3466)
# connection = Denko::Connection::TCP.new("127.0.0.1")
# connection =  Denko::Connection::TCP.new("192.168.1.2", 3466)
#
board = Denko::Board.new(connection)
led = Denko::LED.new(board: board, pin: :LED_BUILTIN)

[:on, :off].cycle do |switch|
  led.send(switch)
  sleep 0.5
end
#
# ser2net can be used to simulate a TCP interface from a board running denko serial.
# It serves the serial interface over a TCP port from the machine running ser2net.
#
# Example ser2net command for an Arduino UNO connected to a Mac:
# ser2net -u -C "3466:raw:0:/dev/cu.usbmodem621:115200"
#
# Tell denko to connect to the IP address of the Mac, at port 3466.
# Note: ser2net should be used in raw TCP mode, not telnet mode (more common).
#
# Replace /dev/cu.usbmodem621 with your denko serial device.
# Arduino UNOs should be something like /dev/ttyACM0 under Linux.
#
# http://sourceforge.net/projects/ser2net/ for more info on installing and configuring ser2net.
#
