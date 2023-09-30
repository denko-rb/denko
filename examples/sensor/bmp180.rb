#
# Example using a BMP180 sensor over I2C, for temperature and pressure.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)
sensor = Denko::Sensor::BMP180.new(bus: bus, address: 0x77)

# Enable oversampling for the pressure sensor only (1,2,4, 8).
# sensor.pressure_samples = 8

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
    formatted_humidity = reading[:humidity].to_f.round(2).to_s.rjust(5, '0')
    print " | Humidity #{formatted_humidity} %"
  end
  
  puts
end

# Poll the sensor and print readings.
sensor.poll(5) do |reading|
  display_reading(reading)
end

sleep
