require_relative '../test_helper'

class DS3231Test < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Denko::I2C::Bus.new(board: board)
  end

  def part
    @part ||= Denko::RTC::DS3231.new(bus: bus)
  end

  def test_time_to_bcd
    time = Time.new(2000, 1, 1, 0, 0, 0.0)
    bytes = part.time_to_bcd(time)
    assert_equal bytes, [0, 0, 0, 6, 1, 1, 48]
  end

  def test_bcd_to_time
    bytes = [0, 0, 0, 6, 1, 1, 48]
    time = part.bcd_to_time(bytes)
    assert_equal time, Time.new(2000, 1, 1, 0, 0, 0.0)
  end

  def test_time=
    mock = Minitest::Mock.new.expect :call, nil, [[0, 0, 0, 0, 6, 1, 1, 48]]
    part.stub(:i2c_write, mock) do
      part.time = Time.new(2000, 1, 1, 0, 0, 0.0)
    end
    mock.verify
  end

  def test_read_and_pre_callback_filter
    board.inject_component_update(part, [0,0,0,6,1,1,48])
    assert_equal Time.new(2000, 1, 1, 0, 0, 0.0), part.time
  end
end
