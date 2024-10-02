#
# Example using an ADS1115 ADC over the I2C bus.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus   = Denko::I2C::Bus.new(board: board)
ads   = Denko::AnalogIO::ADS1115.new(bus: bus)

# Helper method so readings look nice.
def print_reading(name, raw, voltage)
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  print "#{name.rjust(18, " ")} | "
  print "Raw: #{raw.to_s.rjust(6, " ")} | "
  print "Voltage: "
  print ("%.10f" % voltage).rjust(13, " ")
  puts " V"
end

#
# Use the ADS1115 directly by writing values to its config registers.
# ADS1115#read automatically waits for conversion time and gets the 16-bit reading.
# See datasheet for register bitmaps.
#
# Note: This is the only way to use continuous mode. Subcomponents always use one-shot.
#
ads.read([0b11000001, 0b10001011]) do |reading|
  voltage = reading * 0.0001875
  print_reading("Direct", reading, voltage)
end

#
# Or use its BoardProxy interface, adding subcomponents as if it were a Board.
# The key adc: can substitute for board: when intializing AnalogIO::Input.
# Gain and sample rate bitmasks can be found in the datasheet.
#
# Input on pin 0, with pin 1 as differential negative input, and 6.144 V full range.
diff_input = Denko::AnalogIO::Input.new(adc: ads, pin: 0, negative_pin: 1, gain: 0b000)

# Input on pin 2 with no negative input (single ended), and 1.024V full range.
# Ths one uses a 8 SPS rate, essentially 16x oversampling compared to the default 128.
single_input = Denko::AnalogIO::Input.new(adc: ads, pin: 2, gain: 0b011, sample_rate: 0b000)

# Poll the differential input every second.
diff_input.poll(1) do |reading|
  voltage = reading * diff_input.volts_per_bit
  print_reading("Differential A1-A0", reading, voltage)
end

# Poll the single ended input every 2 seconds.
single_input.poll(2) do |reading|
  voltage = reading * single_input.volts_per_bit
  print_reading("Single A2-GN", reading, voltage)
end

sleep
