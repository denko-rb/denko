#
# This helper method can be used in temp/pressure/humidity sensor examples.
# Give a hash with readings as float values and it prints them neatly.
#
def print_tph_reading(reading)
  # Time
  print "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - "
  
  # Temperature
  formatted_temp = reading[:temperature].to_f.round(2).to_s.ljust(5, '0')
  print "Temperature: #{formatted_temp} \xC2\xB0C"
  
  # Pressure
  if reading[:pressure]
    formatted_pressure = (reading[:pressure] / 101325).round(5).to_s.ljust(7, '0')
    print " | Pressure #{formatted_pressure} atm"
  end
  
  # Humidity  
  if reading[:humidity]
    formatted_humidity = reading[:humidity].round(2).to_s.ljust(5, '0')
    print " | Humidity #{formatted_humidity} %"
  end
  
  puts
end
