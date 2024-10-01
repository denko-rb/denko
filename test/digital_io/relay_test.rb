require_relative '../test_helper'

class DigitalIORelaynTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def relay
    @relay ||= Denko::DigitalIO::Relay.new(board: board, pin: 14)
  end

  def test_open_and_close
    relay.close
    assert_equal 1, relay.state
    relay.open
    assert_equal 0, relay.state
  end
end
