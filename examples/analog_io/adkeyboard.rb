#
# This is a small 5 button (D-pad + Enter) module, commonly sold as "AD Keyboard".
# It uses a single analog input. Each button pulls the ADC value down to a
# a different percentage of full scale, which can be detected.
#
require 'bundler/setup'
require 'denko'

PIN = :A0

board     = Denko::Board.new(Denko::Connection::Serial.new)
keyboard  = Denko::AnalogIO::ADKeyboard.new(pin: PIN, board: board)

left, up, down, right, enter = keyboard.buttons

left.down  { puts "pushed left" }
up.down    { puts "pushed up" }
down.down  { puts "pushed down" }
right.down { puts "pushed right" }
enter.down { puts "pushed enter" }

sleep
