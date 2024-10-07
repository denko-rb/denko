require 'bundler/setup'
require 'denko'

SPI_BIT_BANG_PINS = { clock: 13, input: 12, output: 11 }
SELECT_PIN        = 10

board = Denko::Board.new(Denko::Connection::Serial.new)
bus = Denko::SPI::BitBang.new(board: board, pins: SPI_BIT_BANG_PINS)

# Methods so results print neatly. SPI transfers don't block main thread.
def stop_waiting
  $waiting = false
end

def wait_for_read
  $waiting = true
  sleep 0.001 while $waiting
end

# Create a simple test component class.
class SPITester
  include Denko::SPI::Peripheral::SinglePin
end
spi_tester = SPITester.new(bus: bus, pin: SELECT_PIN)

spi_tester.add_callback do |rx_bytes|
  # If MOSI and MISO are connected this should match TEST_DATA.
  # If not, all bytes should be 255.
  puts "Result      : #{rx_bytes.inspect}"
  stop_waiting
end

TEST_DATA = [0, 1, 2, 3, 4, 5, 6, 7]

# Send and receive same data.
puts "Tx 8 / Rx 8 : #{TEST_DATA.inspect}"
spi_tester.spi_transfer(write: TEST_DATA, read: 8)
wait_for_read

puts "Tx 8 / Rx 12: #{TEST_DATA.inspect}"
spi_tester.spi_transfer(write: TEST_DATA, read: 12)
wait_for_read

puts "Tx 8 / Rx 4 : #{TEST_DATA.inspect}"
spi_tester.spi_transfer(write: TEST_DATA, read: 4)
wait_for_read
