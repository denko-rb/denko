require_relative '../test_helper'

class SPITester
  include Denko::SPI::Peripheral::SinglePin

  def some_callback(data)
  end
end

class SPIPeripheralSinglePinTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Denko::SPI::Bus.new(board: board)
  end

  def options
    { bus: bus, pin: 9, spi_frequency: 800000, spi_mode: 2, spi_bit_order: :lsbfirst}
  end

  def part
    @part ||= SPITester.new(options)
  end

  def test_string_data_converts_to_bytes_for_callbacks
    part.on_data do |bytes|
      part.some_callback(bytes)
    end
    mock = Minitest::Mock.new.expect :call, nil, [[127,255]]
    part.stub(:some_callback, mock) do
      board.update("#{part.pin}:127,255")
    end
    mock.verify
  end

  def test_array_data_reaches_callbacks
    part.on_data do |bytes|
      part.some_callback(bytes)
    end
    mock = Minitest::Mock.new.expect :call, nil, [[127,255]]
    part.stub(:some_callback, mock) do
      part.update([127,255])
    end
    mock.verify
  end
end
