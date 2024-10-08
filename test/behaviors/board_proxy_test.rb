require_relative '../test_helper'

class ProxiedComponent
  include Denko::Behaviors::Component
  include Denko::Behaviors::BoardProxy
end

class BoardProxyTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= ProxiedComponent.new(board: board)
  end
  
  def test_methods
    assert_equal part.high, 1
    assert_equal part.low, 0
    assert_equal part.convert_pin("7"), 7
    part.set_pin_mode(1, :output)
    part.start_read
  end
end
