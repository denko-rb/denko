require_relative '../test_helper'

class APII2CTest < Minitest::Test
  include TestPacker

  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Denko::Board.new(connection)
  end

  def test_search
    board
    message = Denko::Message.encode command: 33

    mock = Minitest::Mock.new.expect :call, nil, [message]
    connection.stub(:write, mock) do
      board.i2c_search
    end
    mock.verify
  end

  def test_write
    board
    address = 0x30
    data    = [1,2,3,4]

    # Normal
    aux_stop = pack(:uint8, 0x00) +  pack(:uint8, address | (1 << 7)) + pack(:uint8, data.length) + pack(:uint8, data)
    message1 = Denko::Message.encode command: 34, aux_message: aux_stop
    # Repeated start
    aux_repeat = pack(:uint8, 0x00) +  pack(:uint8, address | (0 << 7)) + pack(:uint8, data.length) + pack(:uint8, data)
    message2   = Denko::Message.encode command: 34, aux_message: aux_repeat

    mock = Minitest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]

    connection.stub(:write, mock) do
      board.i2c_write(0, 0x30, [1,2,3,4])
      board.i2c_write(0, 0x30, [1,2,3,4], 100000, true)
    end
    mock.verify
  end

  def test_write_limits
    assert_raises { board.i2c_write(0, 0x30, Array.new(33) {0x00}) }
    assert_raises { board.i2c_write(0, 0x30, Array.new(0)  {0x00}) }
  end

  def test_read
    board
    address = 0x30

    # Normal
    aux_stop = pack(:uint8, 0x00) + pack(:uint8, address | (1 << 7)) + pack(:uint8, 4) + pack(:uint8, [1, 0x03])
    message1 = Denko::Message.encode command: 35, aux_message: aux_stop
    # Repeated start
    aux_repeat = pack(:uint8, 0x00) + pack(:uint8, address | (0 << 7)) + pack(:uint8, 4) + pack(:uint8, [1, 0x03])
    message2   = Denko::Message.encode command: 35, aux_message: aux_repeat

    mock = Minitest::Mock.new
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]

    connection.stub(:write, mock) do
      board.i2c_read(0, 0x30, 0x03, 4)
      board.i2c_read(0, 0x30, 0x03, 4, 100000, true)
    end
    mock.verify
  end

  def test_read_without_register
    board
    aux = pack(:uint8, 0x00) + pack(:uint8, 0x30 | (1 << 7)) + pack(:uint8, 4) + pack(:uint8, [0])
    message = Denko::Message.encode command: 35, aux_message: aux

    mock = Minitest::Mock.new
    mock.expect :call, nil, [message]

    connection.stub(:write, mock) do
      board.i2c_read(0, 0x30, nil, 4)
    end
    mock.verify
  end

  def test_read_limits
    assert_raises { board.i2c_read(0, 0x30, nil, 33) }
    assert_raises { board.i2c_read(0, 0x30, nil, 0)  }
  end

  def test_frequencies
    board
    data = [1,2,3,4]
    address = 0x30

    messages = []
    # 100 kHz, 400 kHz, 1 Mhz, 3.4 MHz
    aux_after_config = pack(:uint8, 0x30 | (1 << 7)) + pack(:uint8, data.length) + pack(:uint8, data)
    [0x00, 0x01, 0x02, 0x03].each do |code|
      messages << Denko::Message.encode(command: 34, aux_message: pack(:uint8, code) + aux_after_config)
    end

    mock = Minitest::Mock.new
    messages.each do |message|
      mock.expect :call, nil, [message]
    end
    connection.stub(:write, mock) do
      board.i2c_write(0, address, data, 100000)
      board.i2c_write(0, address, data, 400000)
      board.i2c_write(0, address, data, 1000000)
      board.i2c_write(0, address, data, 3400000)
    end
    mock.verify

    assert_raises(ArgumentError) { board.i2c_write(0, 0x30, [1,2,3,4], 5000000, false) }
  end
end
