require_relative '../test_helper'

class AnalogIOPotentiometerTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::AnalogIO::Potentiometer.new(board: board, pin:14)
  end

  def test_setup
    mock = Minitest::Mock.new.expect(:call, nil, [14,8])
    board.stub(:analog_listen, mock) do
      part
    end

    assert_equal 16,  part.divider
    assert_equal [],  part.smoothing_set
  end

  def test_smoothing_on
    part.smoothing = true
    7.times do
      part.update(10)
    end
    part.update(50)

    # 120/8 = 15
    assert_equal 15, part.state
  end

  def test_smoothing_off
    part.smoothing = false
    7.times do
      part.update(10)
    end
    part.update(50)

    # Give latest value.
    assert_equal part.state, 50
  end

  def test_on_change
    mock = Minitest::Mock.new.expect(:call, nil)

    # Turn off smoothing and set an initial value
    part.smoothing = false
    part.update(100)

    # Add the callback
    part.on_change { mock.call }

    # Send a few updates
    part.update(100)
    part.update(100)
    part.update(101)

    # Should have only been called once.
    mock.verify
  end
end
