#
# Example using the ST7565 LCD over SPI.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::Bus.new(board: board)

# Must be connected to SPI bus CLK and MOSI pins, plus select, dc and reset.
# On some modules reset: is marked as "RSE" and dc: as "RS".
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
canvas.text_cursor = 27, baseline+15
canvas.text "Hello World!"

# Add some shapes to the canvas.
canvas.rectangle  x: 10, y: baseline,     w: 30, h: -30
canvas.circle     x: 66, y: baseline-15,  r: 15
canvas.triangle   x1: 87,   y1: baseline,
                  x2: 117,  y2: baseline,
                  x3: 102,  y3: baseline-30

# 1px border, inset 2px from screen edges
canvas.rectangle x1: 2, y1: 2, x2: canvas.x_max-2, y2: canvas.y_max-2

# Show it
lcd.draw
board.finish_write
