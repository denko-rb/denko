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
oled   = Denko::Display::SSD1306.new(bus: bus, width: 128, height: 32)

# Transformation features in hardware.
# oled.reflect_x
# oled.reflect_y
oled.rotate

# Draw some text on the OLED's canvas (a Ruby memory buffer).
canvas = oled.canvas
canvas.text_cursor = 27,31
canvas.text "Hello World!"

# Add some shapes to the canvas.
baseline = 15
canvas.rectangle  x: 10, y: baseline,   w: 14, h: -14
canvas.circle     x: 66, y: baseline-7, r: 8
canvas.triangle   x1: 102, y1: baseline,
                  x2: 118, y2: baseline,
                  x3: 110, y3: baseline-15

# Send the canvas to the OLED's graphics RAM so it shows.
oled.draw
board.finish_write
