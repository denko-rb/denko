require_relative '../test_helper'

class BuzzerTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::PulseIO::Buzzer.new(board: board, pin:8)
  end

  def test_low_on_initialize
    mock = Minitest::Mock.new.expect :call, [part.pin]
    board.stub(:no_tone, mock) do
      part
    end
  end

  def test_tone
    mock = Minitest::Mock.new
    mock.expect :call, nil, [part.pin, 60, nil]
    mock.expect :call, nil, [part.pin, 120, 2000]
    board.stub(:tone, mock) do
      part.tone(60)
      part.tone(120, 2000)
    end
    mock.verify
  end

  def test_no_tone
    part
    mock = Minitest::Mock.new
    mock.expect :call, nil, [part.pin]
    board.stub(:no_tone, mock) do
      part.no_tone
    end
    mock.verify
  end

  def stop
    mock = Minitest::Mock.new
    mock.expect :call, nil
    mock.expect :call, nil
    part.stub(:kill_thread, mock) do
      part.stub(:no_tone, mock) do
        part.stop
      end
    end
    mock.verify
  end
end
