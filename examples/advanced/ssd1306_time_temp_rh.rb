#
# This example polls an HTU21D (temp/humidity sensor) in the background.
# The main thread refreshes an SSD1306 OLED ~20 times per second,
# showing the latest temperature and humidity values, and current time.
# Both devices are conected to the same I2C bus.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
i2c   = Denko::I2C::Bus.new(board: board)

# Get temperature and humidity every second.
htu21d = Denko::Sensor::HTU21D.new(bus: i2c)
htu21d.poll(2)

oled   = Denko::Display::SSD1306.new(bus: i2c, rotate: true)
canvas = oled.canvas

last_refresh = Time.now
loop do
  elapsed = Time.now - last_refresh

  # Aim for 20 fps.
  if elapsed > 0.049
    canvas.clear

    canvas.text_cursor = [0,0]
    canvas.print "Time:  #{Time.now.strftime("%H:%M:%S.%L")}"

    canvas.text_cursor = [0,8]
    canvas.print "Temp:     " + ('%.3f' % htu21d.temperature).rjust(7, " ") + " C"

    canvas.text_cursor = [0,16]
    canvas.print "Humidity: " + ('%.3f' % htu21d.humidity).rjust(7, " ") + " %"

    # Only refresh the area in use.
    oled.draw(0, 127, 0, 24)
    last_refresh = Time.now
  else
    sleep 0.001
  end
end
