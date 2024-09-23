require_relative '../test_helper'

class I2CPeripheralBase
  include Denko::I2C::Peripheral
  I2C_ADDRESS        = 0x30
  I2C_FREQUENCY      = 400_000
  I2C_REPEATED_START = true
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
    @part ||= I2CPeripheralBase.new(bus: bus)
  end

  def test_address
    assert_equal 0x30, part.address
    part2 = I2CPeripheralBase.new(bus: bus, address: 0x31)
    assert_equal 0x31, part2.address
  end

  def test_write_and_repeated_start
    assert_equal true, part.i2c_repeated_start
    mock = Minitest::Mock.new.expect :call, nil, [0x30, [1,2], 400_000, true]
    bus.stub(:write, mock) do
      part.i2c_write [1,2]
    end

    part.i2c_repeated_start = false
    assert_equal false, part.i2c_repeated_start
    mock = Minitest::Mock.new.expect :call, nil, [0x30, [1,2], 400_000, false]
    bus.stub(:write, mock) do
      part.i2c_write [1,2]
    end
  end

  def test_frequency
    assert_equal 400_000, part.i2c_frequency
    mock = Minitest::Mock.new.expect :call, nil, [0x30, [1,2], 400_000, true]
    bus.stub(:write, mock) do
      part.i2c_write [1,2]
    end

    part.i2c_frequency = 100_000
    assert_equal 100_000, part.i2c_frequency
    mock = Minitest::Mock.new.expect :call, nil, [0x30, [1,2], 100_000, true]
    bus.stub(:write, mock) do
      part.i2c_write [1,2]
    end
  end

  def test__read_and_repeated_start
    part.i2c_repeated_start = true

    board.inject_read_for_component(part, 5, "48-127,127,127,127,127,127")

    mock = Minitest::Mock.new.expect :call, nil, [0x30, 0x03, 6, 400_000, true]
    bus.stub(:read, mock) do
      part.i2c_read(6, register: 0x03)
    end
  end
end
