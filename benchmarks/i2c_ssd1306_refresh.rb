#
# Repeatedly writes filled and empty frames to the OLED
# Calculates frames per second. Higher is better.
#
require 'bundler/setup'
require 'denko'

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::I2C::Bus.new(board: board, pin: :SDA)

oled = Denko::Display::SSD1306.new(bus: bus, rotate: true)
canvas = oled.canvas

canvas.print "SSD1306 Benchmark"
oled.draw
sleep 1

frame_count = 100

start = Time.now
(frame_count / 2).times do
  canvas.fill
  oled.draw
  canvas.clear
  oled.draw
end
board.finish_write
finish = Time.now

puts "SSD1306 FPS: #{frame_count / (finish - start)}"
puts
