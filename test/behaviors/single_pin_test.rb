require_relative '../test_helper'

class SinglePinComponent
  include Denko::Behaviors::SinglePin
end

class SinglePinTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= SinglePinComponent.new(board: board, pin: 1)
  end

  def test_requires_pin
    assert_raises(ArgumentError) { SinglePinComponent.new(board: board) }
  end
  
  def test_mode=
    mock = Minitest::Mock.new
    mock.expect :call, nil, [1, :some_mode] 

    board.stub(:set_pin_mode, mock) do
      part.mode = :some_mode
    end
    mock.verify
    
    assert_equal :some_mode, part.mode
  end

  def test_converts_pin_before_saving
    c1 = SinglePinComponent.new(board: board, pin: :DAC0)
    c2 = SinglePinComponent.new(board: board, pin: :A1)
    c3 = SinglePinComponent.new(board: board, pin: :SDA)

    assert_equal 14, c1.pin
    assert_equal 15, c2.pin
    assert_equal 20, c3.pin
  end
end
