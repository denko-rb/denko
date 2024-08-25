require_relative '../test_helper'

class OutputComponent
  include Denko::Behaviors::OutputPin
end

class OutputPinTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def test_set_mode
    modes = [:output, :output_pwm, :output_dac, :output_open_drain, :output_open_source]

    mock = Minitest::Mock.new
    modes.each_with_index do |mode, pin|
      mock.expect :call, nil, [pin+1, mode]
    end

    board.stub(:set_pin_mode, mock) do
      modes.each_with_index do |mode, pin|
        part = OutputComponent.new(board: board, pin: pin+1, mode: mode)
        assert_equal mode, part.mode
      end
    end
    mock.verify
    
    assert_raises { OutputComponent.new(board: board, pin: modes.count+1, mode: :wrong_mode) }
  end
end
