require_relative '../test_helper'

class DigitalIOInputTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::DigitalIO::Input.new(board: board, pin: 14)
  end

  def test_start_listening_immediately
    mock = Minitest::Mock.new.expect :call, nil, [14, 4]
    board.stub(:digital_listen, mock) do
      part
    end
    mock.verify
  end

  def test_converts_to_integer
    part
    part.update("1")
    assert_equal part.state, 1
  end

  def test_read
    board.inject_component_update(part, 0)
    mock = Minitest::Mock.new.expect :call, nil, [14]
    board.stub(:digital_read, mock) do
      part.read
    end
    mock.verify
  end

  def test__listen
    part
    mock = Minitest::Mock.new
    mock.expect :call, nil, [14, 4]
    mock.expect :call, nil, [14, 32]
    board.stub(:digital_listen, mock) do
      part._listen
      part._listen(32)
    end
    mock.verify
  end

  def test_on_low
    low_cb  = Minitest::Mock.new.expect :call, nil
    high_cb = Minitest::Mock.new
    part.on_low { low_cb.call }
    part.on_high { high_cb.call }
    part.update(board.low)
    low_cb.verify
    high_cb.verify
  end

  def test_on_high
    low_cb  = Minitest::Mock.new
    high_cb = Minitest::Mock.new.expect :call, nil
    part.on_low { low_cb.call }
    part.on_high { high_cb.call }
    part.update(board.high)
    low_cb.verify
    high_cb.verify
  end
end
