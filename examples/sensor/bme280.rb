#
# Example using a BME280 sensor over I2C, for temperature, pressure and humidity.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)

sensor = Denko::Sensor::BME280.new(bus: bus, address: 0x76)
# Use A BMP280 with no humidity instead.
# sensor = Denko::Sensor::BMP280.new(bus: bus, address: 0x76)

# Default reading mode is oneshot ("forced" in datasheet).
# sensor.oneshot_mode

# Enable oversampling independently on each sensor.
# sensor.temperature_samples = 8
# sensor.pressure_samples = 2
# sensor.humidity_samples = 4

# Enable continuous reading mode ("normal" in datasheet), with standby time and IIR filter.
# sensor.continuous_mode
# sensor.standby_time = 62.5
# sensor.iir_coefficient = 4

# Print raw config register bits.
# print sensor.config_register_bits

def display_reading(reading)
  # Time
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  
  # Temperature
  formatted_temp = reading[:temperature].to_f.round(2).to_s.ljust(5, '0')
  print "Temperature: #{formatted_temp} \xC2\xB0C"
  
  # Pressure
  if reading[:pressure]
    formatted_pressure = (reading[:pressure].to_f / 101325).round(5).to_s.ljust(7, '0')
    print " | Pressure #{formatted_pressure} atm"
  end
  
  # Humidity  
  if reading[:humidity]
    formatted_humidity = reading[:humidity].to_f.round(2).to_s.ljust(5, '0')
    print " | Humidity #{formatted_humidity} %"
  end
  
  puts
end

# Poll the sensor and print readings.
sensor.poll(5) do |reading|
  display_reading(reading)
end

sleep
