#
# Example using the reflective ST7302 reflective LCD over SPI.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::Bus.new(board: board)

# Must be connected to SPI bus CLK and MOSI pins, plus select, dc and reset.
lcd = Denko::Display::ST7302.new(bus: bus, pins: { select: 10, dc: 9, reset: 8 })
canvas = lcd.canvas

# Draw some text on the canvas (a Ruby memory buffer).
baseline = 75
canvas.text_cursor = [32,baseline+35]
canvas.font = Denko::Fonts::LED_8x16
canvas.font_scale = 2
canvas.text "Hello World!"

# Add some shapes.
canvas.rectangle(20, baseline, 60, -60)
canvas.circle(125, baseline -30, 30)
triangle_x = 170
canvas.triangle(triangle_x, baseline, triangle_x+60, baseline, triangle_x+30, baseline-60)

# 1px border, inset by 2, to test screen edges.
canvas.rectangle(2, 2, lcd.columns-5, lcd.rows-5)

# Invert it or reset to normal
# lcd.invert_on
# lcd.invert_off

# Frame rate can be any of [0.25, 0,5, 1, 2, 4, 8, 16, 32]. Default is 8
# lcd.frame_rate = 4

# Show it
lcd.draw
board.finish_write
