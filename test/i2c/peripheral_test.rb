require_relative '../test_helper'

class I2CPeripheralBase
  include Denko::I2C::Peripheral
end

class I2CPeripheralTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    return @bus if @bus
    @bus = Denko::I2C::Bus.new(board: board, pin:5)
    @bus
  end
  
  def part
    @part ||= I2CPeripheralBase.new(bus: bus, i2c_address: 0x30)
  end
    
  def test_write_and_repeated_start
    part.i2c_repeated_start = true
    
    mock = Minitest::Mock.new.expect :call, nil, [0x30, [1,2], 100000, true]
    bus.stub(:write, mock) do
      part.i2c_write [1,2]
    end
  end

  def test_frequency
    part.i2c_frequency = 400000
    
    mock = Minitest::Mock.new.expect :call, nil, [0x30, [1,2], 400000, false]
    bus.stub(:write, mock) do
      part.i2c_write [1,2]
    end
  end
  
  def test__read_and_repeated_start
    part.i2c_repeated_start = true
    
    board.inject_read_for_component(part, 5, "48-127,127,127,127,127,127")
    
    mock = Minitest::Mock.new.expect :call, nil, [0x30, 0x03, 6, 100000, true]
    bus.stub(:read, mock) do
      part.i2c_read(6, register: 0x03)
    end
  end
end
