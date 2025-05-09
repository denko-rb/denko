require_relative '../test_helper'

class AnalogIOInputTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::AnalogIO::Input.new(board: board, pin: 14)
  end

  def test__read
    mock = Minitest::Mock.new.expect :call, nil, [14, nil, nil, nil]
    board.stub(:analog_read, mock) do
      part.read_nb
    end
    mock.verify
  end

  def test__listen
    mock = Minitest::Mock.new
    mock.expect :call, nil, [14, 16]
    mock.expect :call, nil, [14, 32]
    board.stub(:analog_listen, mock) do
      part._listen
      part._listen(32)
    end
    mock.verify
  end

  def test__stop_listen
    mock = Minitest::Mock.new.expect :call, nil, [14]
    board.stub(:stop_listener, mock) do
      part._stop_listener
    end
    mock.verify
  end
end
