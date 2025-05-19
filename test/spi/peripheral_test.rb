require_relative '../test_helper'

class SPITester
  include Denko::SPI::Peripheral

  def initialize_pins(options={})
    super(options)
    proxy_pin :other_pin, Denko::DigitalIO::Output
  end

  def some_callback(data)
  end
end

class SPITesterSingle
  include Denko::SPI::Peripheral
end

class SPIPeripheralTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Denko::SPI::Bus.new(board: board)
  end

  def options
    { bus: bus, pins: {select: 9, other_pin: 10}, spi_frequency: 800000, spi_mode: 2, spi_bit_order: :lsbfirst}
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
      board.update("#{part.select.pin}:127,255")
    end
    mock.verify
  end

  def test_array_data_reaches_callbacks
    part.on_data do |bytes|
      part.some_callback(bytes)
    end
    mock = Minitest::Mock.new.expect :call, nil, [[127,255]]
    part.stub(:some_callback, mock) do
      part.select.update([127,255])
    end
    mock.verify
  end

  def test_allows_pin_alone
    part2 = SPITesterSingle.new(bus: bus, pin: 5)
    assert bus.components.include?(part2)
  end

  def test_subcomponents_attach_to_board_not_bus
    part
    assert board, part.select.board
    assert board, part.other_pin.board
  end

  def test_added_to_bus
    part
    assert bus.components.include?(part)
  end
end
