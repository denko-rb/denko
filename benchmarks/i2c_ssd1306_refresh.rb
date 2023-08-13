#
# Repeatedly writes filled and empty frames to the OLED
# Calculates frames per second. Higher is better.
#
# RESULTS:
# July 6 2023 | i7 8700k CPU | CRuby 3.2.1 | 100 frames | 1 Mhz I2C frequency | Average of 3 runs
#
#   Arduino Uno R3      :  5.3 fps (ATmega16u2 UART bridge @ 115200, no I2C level shifter)
#   Arduino Uno R3      :  7.1 fps (ATmega16u2 UART bridge @ 230400, no I2C level shifter)
#   Arduino Leonardo    : 12.9 fps (native USB, no I2C level shifter)
#   Arduino Due         : 43.0 fps (native USB)
#   Arduino Due         :  7.9 fps (programming USB @ 115200)
#   Arduino Zero        : 28.6 fps (native USB)
#   Arduino Zero        :  9.4 fps (programming USB @ 115200)
#   Arduino Zero        : 13.6 fps (programming USB @ 230400)
#   ESP8266 (Node MCU)  :  9.9 fps (Silicon Labs UART bridge @ 115200)
#   ESP8266 (Node MCU)  : 19.7 fps (Silicon Labs UART bridge @ 230400)
#   ESP32 V1            :  9.8 fps (Silicon Labs UART bridge @ 115200)
#   ESP32 V1            : 19.4 fps (Silicon Labs UART bridge @ 230400)
#   ESP32-S3            : 58.8 fps (native USB)
#   Raspberry Pi Pico W : 36.4 fps (native USB)
#
# July 15 2023 | i7 8700k CPU | CRuby 3.2.1 | 100 frames | 1 Mhz I2C frequency | Average of 3 runs
#
#   Arduino Uno R4 WiFi :  7.5 fps (USB through ESP32-S3 @ 115200, 32-byte I2C limit, no I2C level shifter)
#   Arduino Uno R4 WiFi :  7.8 fps (USB through ESP32-S3 @ 230400, 32-byte I2C limit, no I2C level shifter)
#
# August 13 2023 | i7 8700k CPU | CRuby 3.2.1 | 100 frames | 1 Mhz I2C frequency | Average of 3 runs
#
#   Arduino Nano Every  :  9.2 fps (USB through ATSAMD11 @ 115200, 128-byte I2C limit, no I2C level shifter)
#   Arduino Nano Every  : 13.0 fps (USB through ATSAMD11 @ 230400, 128-byte I2C limit, no I2C level shifter)
#
require 'bundler/setup'
require 'denko'

# Settings
# Must match speed in the sketch for UART briges. Doesn't matter for native USB.
BAUD_RATE = 115_200
FRAME_COUNT = 100
# Request 1 Mhz I2C frequency. Wire libraries will fall back to fastest available speed.
I2C_FREQUENCY = 1_000_000
# Use :SDA0 for RP2040
I2C_PIN = :SDA

# Setup
board = Denko::Board.new(Denko::Connection::Serial.new(baud: BAUD_RATE))
bus = Denko::I2C::Bus.new(board: board, pin: I2C_PIN)
oled = Denko::Display::SSD1306.new(bus: bus, rotate: true, i2c_frequency: I2C_FREQUENCY)
canvas = oled.canvas

# Intro
canvas.print "SSD1306 Benchmark"
oled.draw
sleep 1

# Run
start = Time.now
(FRAME_COUNT / 2).times do
  canvas.fill
  oled.draw
  canvas.clear
  oled.draw
end
board.finish_write
finish = Time.now

# Calculate results
fps = FRAME_COUNT / (finish - start)

# Print to terminal
puts "SSD1306 benchmark result: #{fps.round(2)} fps"
puts

# Print to screen
canvas.clear
canvas.text_cursor = [0,0]
canvas.print "#{fps.round(2)} fps"
oled.draw
board.finish_write
