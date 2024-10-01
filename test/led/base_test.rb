require_relative '../test_helper'

class BaseLEDTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::LED::Base.new(board: board, pin:1)
  end

  def test_led_new_creates_base_led
    part = Denko::LED.new(board: board, pin:2)
    assert_equal Denko::LED::Base, part.class
  end

  def test_blink_runs_in_thread_and_sets_ivar
    mock = Minitest::Mock.new.expect :call, nil
    part.stub(:threaded_loop, mock) do
      part.blink(0.5)
    end
    mock.verify
    assert_equal 0.5, part.blink_interval
  end
end
