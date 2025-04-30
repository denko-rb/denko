#
# Example using the ST7565 LCD over SPI.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::Bus.new(board: board)

# Must be connected to SPI bus CLK and MOSI pins, plus select, dc and reset.
lcd = Denko::Display::ST7565.new(bus: bus, pins: { select: 10, dc: 9, reset: 8 })

# Rotate it 180 degrees and invert colors.
lcd.rotate
lcd.invert

# Initial draw to clear display RAM
lcd.draw

# Other options
# lcd.reflect_x
# lcd.reflect_y
# lcd.standby
# lcd.slp
# lcd.wake
lcd.volume = 16

canvas = lcd.canvas

# Draw some text on the canvas (a Ruby memory buffer).
baseline = 42
canvas.text_cursor = [27,baseline+15]
canvas.print("Hello World!")

# Add some shapes to the canvas.
canvas.rectangle(10, baseline, 30, -30)
canvas.circle(66, baseline - 15, 15)
canvas.triangle(87, baseline, 117, baseline, 102, baseline - 30)

# 1px border to test screen edges.
canvas.rectangle(2, 2, lcd.columns-5, lcd.rows-5)

# Show it
lcd.draw
board.finish_write
