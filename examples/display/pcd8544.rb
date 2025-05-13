#
# Example using the PCD8544 (Nokia 5110) LCD over SPI.
# It is 84 pixels wide x 48 pixels high.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::Bus.new(board: board)

# Must be connected to SPI bus CLK and MOSI pins, plus select, dc and reset.
lcd = Denko::Display::PCD8544.new(bus: bus, pins: { select: 10, dc: 9, reset: 8 })

# No rotation in hardware. Do it with canvas.
canvas = lcd.canvas
canvas.rotate(180)

# Initial draw to clear display RAM
lcd.draw

# Other features:
#
# Vop (essentially contrast?). Range is 0..127. Default is 56.
# lcd.vop = 56
#
# Bias. Range is 0..7. Default is 4.
# lcd.bias = 4
#
# Temperature control coefficient. Might be applicable at low temps? Default is 0.
# lcd.temperature_coefficient = 0
#
# Inversion in hardware. Bias=2 looks best while inverted.
# lcd.invert # happens immediately, not on next #draw, like other displays.
# lcd.bias = 2

# Draw some text on the canvas (a Ruby memory buffer).
#
# Note: The pixels on this display seem to have a non-square aspect ratio.
# Their width is about 0.8 of their height. Coordinates below are modified to compensate.
#
baseline = 28
canvas.text_cursor = [7, baseline+12]
canvas.text "Hello World!"

# Add some shapes to the canvas.
canvas.rectangle(3, baseline, 20, -16)
canvas.ellipse(38, baseline - 8, 10, 8)
canvas.triangle(49, baseline, 81, baseline, 81-15, baseline-16)

# 1px border to test screen edges.
canvas.rectangle(0, 0, lcd.columns-1, lcd.rows-1)

# Show it
lcd.draw
board.finish_write
