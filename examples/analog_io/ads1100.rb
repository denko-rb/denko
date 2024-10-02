#
# Example using an ADS1100 ADC over the I2C bus.
#
require 'bundler/setup'
require 'denko'

# Helper method so readings look nice.
def print_reading(name, raw, voltage)
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  print "#{name.rjust(9, " ")} | "
  print "Raw: #{raw.to_s.rjust(6, " ")} | "
  print "Voltage: "
  print ("%.10f" % voltage).rjust(13, " ")
  puts " V"
end

board = Denko::Board.new(Denko::Connection::Serial.new)
bus   = Denko::I2C::Bus.new(board: board)

# Unlike the ADS1115/1118, full-scale voltage depends on Vdd. Give during setup.
# This works for my M5Stack ADC unit (0-12V) when checked against a multimeter.
ads = Denko::AnalogIO::ADS1100.new  bus: bus,
                                    full_scale_voltage: 26.408,
                                    sample_rate: 16,
                                    gain: 2
                                    # address: 0x48 default

#
# Configure gain and sample rate. See datasheet for more info.
# Valid values:
#   Gain:         1 (default), 2,  4,  8
#   Sample Rate:  8 (default), 16, 32, 128
#
ads.gain        = 1
ads.sample_rate = 8

# Configure smoothing.
ads.smoothing       = true
ads.smoothing_size  = 8

# Poll and print indefinitely.
ads.poll(0.25) do |reading|
  # volts_per_bit calculated from full-scale voltage, gain and sample rate.
  voltage = reading * ads.volts_per_bit
  print_reading("ADS1100:", reading, voltage)
end

sleep
