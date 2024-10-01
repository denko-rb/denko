require_relative '../test_helper'

class DigitalIOButtonTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::DigitalIO::Button.new(board: board, pin: 14)
  end

  def test_divider_set_correctly
    assert_equal 1, part.divider
  end
end
