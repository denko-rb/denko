require_relative '../test_helper'

class TempSpiPeripheral
  include Denko::SPI::Peripheral
end

class SPIBusTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @bus ||= Denko::SPI::Bus.new(board: board, index: 5)
  end

  PIN = 9
  OPTIONS = { read: 2, frequency: 800000, mode: 2, bit_order: :lsbfirst }

  def test_automatically_adds_and_removes_component
    obj = TempSpiPeripheral.new(bus: part, pin: 1)
    assert part.components.include?(obj)

    part.remove_component(obj)
    refute part.components.include?(obj)
  end

  def test_unique_select_pins
    TempSpiPeripheral.new(bus: part, pin: 1)

    assert_raises do
      TempSpiPeripheral.new(bus: part, pin: 1)
    end
  end

  def test_transfer
    mock = Minitest::Mock.new.expect :call, nil, [5, PIN], **OPTIONS
    board.stub(:spi_transfer, mock) do
      part.transfer(PIN, **OPTIONS)
    end
    mock.verify
  end

  def test_listen
    mock = Minitest::Mock.new.expect :call, nil, [5, PIN], **OPTIONS
    board.stub(:spi_listen, mock) do
      part.listen(PIN, **OPTIONS)
    end
    mock.verify
  end

  def test_stop_forwarded
    mock = Minitest::Mock.new.expect :call, nil, [PIN]
    board.stub(:spi_stop, mock) do
      part.stop(PIN)
    end
    mock.verify
  end

  def test_set_pin_mode_forwarded
    mock = Minitest::Mock.new.expect :call, nil, [9, :output]
    board.stub(:set_pin_mode, mock) do
      part.set_pin_mode(9, :output)
    end
    mock.verify
  end
end
