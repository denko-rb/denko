#
# PWM (pulse width modulation) output demo.
# Frequency and resolution are configurable (only on ESP32 and PiBoard/Linux for now).
# Capture output with logic analyzer or oscilloscope to verify accuracy.
#
require 'bundler/setup'
require 'denko'

PIN = 2

board = Denko::Board.new(Denko::Connection::Serial.new)
pwm = Denko::PulseIO::PWMOutput.new(board: board, pin: PIN)

# Resolution test: ~1% duty at 1 kHz / 10-bit.
# On and off approx. 10us and 990us respectively.
pwm.pwm_enable(frequency: 1_000, resolution: 10)
pwm.write 10 # of 1023
sleep 0.5
pwm.digital_write 0

sleep 0.5

# Frequency test: ~50% duty at 10 kHz / 8-bit.
# On and off both approx. 50us.
pwm.pwm_enable(frequency: 10_000, resolution: 8)
pwm.write 127 # of 255
sleep 0.5
pwm.digital_write 0

board.finish_write
