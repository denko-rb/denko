require_relative '../test_helper'

class InputComponent
  include Denko::Behaviors::InputPin
end

class InputPinTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= InputComponent.new(board: board, pin: 1)
  end

  def test_mode_and_pullup
    modes = [:input, :input_pulldown, :input_pullup]

    mock = Minitest::Mock.new
    modes.each_with_index do |mode, pin|
      mock.expect :call, nil, [pin+1, mode]
    end
    
    board.stub(:set_pin_mode, mock) do
      modes.each_with_index do |mode, pin|
        local_part = InputComponent.new(board: board, pin: pin+1, mode: mode)
        assert_equal mode, local_part.mode
      end
    end
    mock.verify
    
    assert_raises { InputComponent.new(board: board, pin: modes.count+1, mode: :wrong_mode) }
  end

  def test_debounce_time=
    part.debounce_time = 1
  end

  def test_stop_listener
    mock = Minitest::Mock.new
    mock.expect :call, nil, [1]
    board.stub(:stop_listener, mock) do
      part._stop_listener
    end
    mock.verify
  end
end
