#
# This example shows how to smooth the input of an AnalogIO::Input.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
input = Denko::AnalogIO::Input.new(pin: :A0, board: board)

# Enable smoothing on the input using the last 16 values.
input.smoothing = true
input.smoothing_size = 16

# Use the slowest listener possible.
input.listen(128)

#
# With these settings, the input's state should gradually change (~2 seconds),
# if you switch its supply from Vcc to Ground (or vice versa), instead of instantaneously.
#
# Print the state every 1/4 second. Change the voltage being input to the pin to see results.
loop do
  puts input.state
  sleep(0.25)
end
