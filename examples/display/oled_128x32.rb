#
# Generic example for 128x32 OLEDs, usually only SSD1306 over I2C.
# Also covers the one built into the Lolin ESP32-S2 Pico.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)

# Modules usually have reset permanently tied high.
# Lolin ESP32-S2 has it connected to pin 18. Do it manually.
# reset = Denko::DigitalIO::Output.new(board: board, pin: 18)
# reset.high

bus    = Denko::I2C::Bus.new(board: board, index: 0)
# bus = Denko::I2C::BitBang.new(board: board, pins: {scl: 4, sda: 5})
oled   = Denko::Display::SSD1306.new(bus: bus, width: 128, height: 32, rotate: true)
canvas = oled.canvas

# Draw some text on the OLED's canvas (a Ruby memory buffer).
canvas.text_cursor = [27,31]
canvas.print("Hello World!")

# Add some shapes to the canvas.
baseline = 15
canvas.rectangle(10, baseline, 15, -15)
canvas.circle(66, baseline - 7, 8)
canvas.triangle(102, baseline, 118, baseline, 110, baseline - 15)

# Send the canvas to the OLED's graphics RAM so it shows.
oled.draw
board.finish_write
