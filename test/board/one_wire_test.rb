require_relative '../test_helper'

class APIOneWireTest < Minitest::Test
  include TestPacker

  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Denko::Board.new(connection)
  end

  def test_one_wire_reset
    board
    message = Denko::Message.encode command: 41, pin: 1, value: 0

    mock = Minitest::Mock.new.expect :call, nil, [message]
    connection.stub(:write, mock) do
      board.one_wire_reset(1, false)
    end
    mock.verify
  end

  def test_one_wire_reset_with_presence
    board
    message = Denko::Message.encode command: 41, pin: 1, value: 1

    mock = Minitest::Mock.new.expect :call, nil, [message]
    connection.stub(:write, mock) do
      board.one_wire_reset(1, true)
    end
    mock.verify
  end

  def test_one_wire_search
    board
    message = Denko::Message.encode command: 42, pin: 1, aux_message: pack(:uint64, 128, max:8)

    mock = Minitest::Mock.new.expect :call, nil, [message]
    connection.stub(:write, mock) do
      board.one_wire_search(1, 128)
    end
    mock.verify
  end

  def test_one_wire_write
    board

    # Calculate length and parasite power properly.
    message1 = Denko::Message.encode command: 43, pin: 1, value: 0b10000000 | 3, aux_message: pack(:uint8, [1,2,3])
    message2 = Denko::Message.encode command: 43, pin: 1, value: 4, aux_message: pack(:uint8, [1,2,3,4])

    mock = Minitest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    connection.stub(:write, mock) do
      board.one_wire_write(1, true, [1,2,3])
      board.one_wire_write(1, nil, [1,2,3,4])
    end
    mock.verify

    # Don't allow more than 127 bytes of data.
    assert_raises(ArgumentError) do
      too_big = Array.new(128).map { 42 }
      board.one_wire_write(1, true, too_big)
    end
  end

  def test_one_wire_read
    board
    message = Denko::Message.encode command: 44, pin: 1, value: 9

    mock = Minitest::Mock.new.expect :call, nil, [message]
    connection.stub(:write, mock) do
      board.one_wire_read(1, 9)
    end
    mock.verify
  end
end
