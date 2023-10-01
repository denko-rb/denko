#
# Example using SHT30/31/35 sensor over I2C, for temperature and humidity.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)
sensor = Denko::Sensor::SHT3X.new(bus: bus)

# Heater control
sensor.heater_on
puts "Heater on: #{sensor.heater_on?}"
sensor.heater_off
puts "Heater off: #{sensor.heater_off?}"

# Reset (turns heater off)
sensor.reset
puts "Resetting..."
puts "Heater off: #{sensor.heater_off?}"
puts

# Set repeatability= :low, :medium or :high (default). See datasheet for details.
sensor.repeatability = :high

# Helper to print readings neatly.
def display_reading(reading)
  # Time
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  
  # Temperature
  formatted_temp = reading[:temperature].to_f.round(2).to_s.ljust(5, '0')
  print "Temperature: #{formatted_temp} \xC2\xB0C"

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
