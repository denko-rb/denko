require_relative '../test_helper'

class IROutPutTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::PulseIO::IROutput.new(board: board, pin:1)
  end

  def test_does_not_set_pin_mode
    refute part.params[:mode]
    refute part.mode
  end

  def test_pulse_count_validation
    assert_raises(ArgumentError) do
      part.write Array.new(256) { 0 }
    end
  end

  def test_numeric_validation
    assert_raises(ArgumentError) do
      part.write ["a", "b", "c"]
    end
  end

  def test_pulse_length_validation
    assert_raises(ArgumentError) do
      part.write [65536]
    end
  end

  def test_emits
    part
    mock = Minitest::Mock.new.expect(:call, nil, [1, 38, [127,0]])
    board.stub(:infrared_emit, mock) do
      part.write([127,0])
    end
    mock.verify
  end
end
