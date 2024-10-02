#
# Connect to a Board via TCP. This works for WiFi and Ethernet sketches.
# Default port is 3466, and must match the port the Board was flashed to listen on.
#
require 'bundler/setup'
require 'denko'

IP_ADDRESS  = "192.168.0.52"
PORT        = 3466
PIN         = :LED_BUILTIN

connection  = Denko::Connection::TCP.new(IP_ADDRESS, PORT)
board       = Denko::Board.new(connection)
led         = Denko::LED.new(board: board, pin: PIN)

[:on, :off].cycle do |switch|
  led.send(switch)
  sleep 0.5
end
