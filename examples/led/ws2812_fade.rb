#
# Fade colors along a WS2812, and over time.
#
require 'bundler/setup'
require 'denko'

WS2812_PIN = 4
PIXELS     = 8

board = Denko::Board.new(Denko::Connection::Serial.new)
strip = Denko::LED::WS2812.new(board: board, pin: WS2812_PIN, length: PIXELS)

min = 0
max = 255
gap = 5
values = (min..max).step(gap).to_a + (min..max-gap).step(gap).to_a.reverse

color_values= []
# Red
values.each { |v| color_values << [v, 0, 0] }
# Green
values.each { |v| color_values << [0, v, 0] }
# Blue
values.each { |v| color_values << [0, 0, v] }
# White
values.each { |v| color_values << [v, v, v] }

loop do
  start  = 0
  finish = PIXELS - 1
  while (finish < color_values.length)
    slice = color_values[start..finish]

    slice.each_with_index do |value, i|
      strip[i] = value
    end
    strip.show
    sleep 0.025

    start  += 1
    finish += 1
  end
end
