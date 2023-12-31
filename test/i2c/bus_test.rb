require_relative '../test_helper'

class I2CPeripheralBase
  include Denko::I2C::Peripheral
end

class I2CBusTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    return @part if @part
    @part = Denko::I2C::Bus.new(board: board, pin:5)
    @part
  end
  
  def peripheral
    @peripheral ||= I2CPeripheralBase.new(bus: part, address: 0x30)
  end

  def test_initialize
    assert_equal part.found_devices, []
    refute_nil part.callbacks[:bus_controller]
  end

  def test_search
    board.inject_read_for_pin(5, "48:50")

    mock = Minitest::Mock.new.expect :call, nil
    board.stub(:i2c_search, mock) do
      part.search
    end
    mock.verify

    assert_equal part.found_devices, [0x30, 0x32]
  end

  def test_write
    mock = Minitest::Mock.new.expect :call, nil, [0x30, [0x01, 0x02], 100000, false]
    board.stub(:i2c_write, mock) do
      part.write 0x30, [0x01, 0x02]
    end
    mock.verify
  end
  
  def test__read
    board.inject_read_for_pin(5, "48-255,0,255,0,255,0")
    
    mock = Minitest::Mock.new.expect :call, nil, [0x32, 0x03, 6, 100000, false]
    board.stub(:i2c_read, mock) do
      part.read 0x32, 0x03, 6
    end
    mock.verify
  end
  
  def test_updates_peripherals
    mock = Minitest::Mock.new.expect :call, nil, [[255, 127]]
    
    peripheral.stub(:update, mock) do
      part.send(:update, "48-255,127")
      part.send(:update, "50-128,0")
    end
    mock.verify
  end
end
