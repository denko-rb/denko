#
# Example looping the Arduino Zero's DAC back into one of its ADC pins.
#
require 'bundler/setup'
require 'denko'

#
# Arduino Zero:   :DAC0 is :A0 is GPIO14
# Arduino UNO R4: :DAC  is :A0 is GPIO14
# ESP32 V1:       :DAC0 is GPIO25, :DAC1 is GPIO26, :A4 is GPIO32
# ESP32-S2:       :DAC0 is GPIO17, :DAC1 is GPIO18, :A4 is GPIO5
#
# Connect DAC_PIN TO ADC_PIN with a jumper to test.
#
DAC_PIN = :DAC0
ADC_PIN = :A4

board = Denko::Board.new(Denko::Connection::Serial.new)
dac = Denko::AnalogIO::Output.new(pin: DAC_PIN, board: board)
adc = Denko::AnalogIO::Input.new(pin: ADC_PIN, board: board)

#
# Read values should be approximately 4x the written values, since Board#new tries to
# set output resolution at 8-bits and input to 10-bits. Not configurable on all chips.
# Scale may be off but, readings should still be proportional.
#
[0, 32, 64, 128, 192, 255].each do |output_value|
  dac.write output_value
  sleep 1
  loopback_value = adc.read
  puts "ADC reads: #{loopback_value} when DAC writes: #{output_value}"
end

board.finish_write
