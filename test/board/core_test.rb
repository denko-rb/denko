require_relative '../test_helper'

class BoardCoreTest < Minitest::Test
  include TestPacker

  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Denko::Board.new(connection)
  end

  def test_set_pin_mode
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [Denko::Message.encode(command: 0, pin: 1, value: 0b000)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 0, pin: 1, value: 0b010, aux_message: pack(:uint32, [0, 0]))])
    mock.expect(:call, nil, [Denko::Message.encode(command: 0, pin: 1, value: 0b010, aux_message: pack(:uint32, [1000, 12]))])
    mock.expect(:call, nil, [Denko::Message.encode(command: 0, pin: 1, value: 0b100)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 0, pin: 1, value: 0b001)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 0, pin: 1, value: 0b011)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 0, pin: 1, value: 0b101)])

    board.stub(:write, mock) do
      board.set_pin_mode 1, :output
      board.set_pin_mode 1, :output_pwm
      board.set_pin_mode 1, :output_pwm, frequency: 1000, resolution: 12
      board.set_pin_mode 1, :output_dac
      board.set_pin_mode 1, :input
      board.set_pin_mode 1, :input_pulldown
      board.set_pin_mode 1, :input_pullup
    end
    mock.verify

    assert_raises { board.set_pin_mode 1, "wrong" }
  end

  def test_set_pin_debounce
    board.set_pin_debounce(1, 1)
  end

  def test_digital_write
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [Denko::Message.encode(command: 1, pin: 1, value: board.low)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 1, pin: 1, value: board.high)])

    board.stub(:write, mock) do
      board.digital_write 1, board.low
      board.digital_write 1, board.high
    end
    mock.verify

    assert_raises { board.digital_write 1, "wrong" }
  end

  def test_digital_read
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [Denko::Message.encode(command: 2, pin: 1)])

    board.stub(:write, mock) do
      board.digital_read 1
    end
    mock.verify
  end

  def test_pwm_write
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [Denko::Message.encode(command: 3, pin: 1, value: board.low)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 3, pin: 1, value: board.pwm_high)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 3, pin: 1, value: 128)])

    board.stub(:write, mock) do
      board.pwm_write 1, board.low
      board.pwm_write 1, board.pwm_high
      board.pwm_write 1, 128
    end
    mock.verify

    assert_raises { board.pwm_write 1, "wrong" }
  end

  def test_dac_write
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [Denko::Message.encode(command: 4, pin: 1, value: board.low)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 4, pin: 1, value: board.dac_high)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 4, pin: 1, value: 128)])

    board.stub(:write, mock) do
      board.dac_write 1, board.low
      board.dac_write 1, board.dac_high
      board.dac_write 1, 128
    end
    mock.verify

    assert_raises { board.dac_write 1, "wrong" }
  end

  def test_analog_read
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [Denko::Message.encode(command: 5, pin: 1)])

    board.stub(:write, mock) do
      board.analog_read 1
    end
    mock.verify
  end

  def test_set_listener
    mock = Minitest::Mock.new

    # \x00\x02 corresponds to the default digital divider of 4 (2^2).
    # \x00\x04 corresponds to the default analog divider of 16 (2^4).
    mock.expect(:call, nil, [Denko::Message.encode(command: 6, pin: 1, value: 0, aux_message: "\x00\x02")])
    mock.expect(:call, nil, [Denko::Message.encode(command: 6, pin: 1, value: 0, aux_message: "\x01\x04")])
    mock.expect(:call, nil, [Denko::Message.encode(command: 6, pin: 1, value: 1, aux_message: "\x01\x04")])
    mock.expect(:call, nil, [Denko::Message.encode(command: 6, pin: 1, value: 1, aux_message: "\x01\x00")])

    board.stub(:write, mock) do
      board.set_listener(1, :off)
      board.set_listener(1, :off, mode: :analog)
      board.set_listener(1, :on, mode: :analog)
      board.set_listener(1, :on, mode: :analog, divider: 1)
    end
    mock.verify

    assert_raises { board.set_listener 1, :on, mode: "wrong" }
    assert_raises { board.set_listener 1, :on, divider: 256 }
  end

  def test_digital_listen
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [1, :on], mode: :digital, divider: 4)

    board.stub(:set_listener, mock) do
      board.digital_listen(1)
    end
  end

  def test_analog_listen
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [1, :on], mode: :analog, divider: 16)

    board.stub(:set_listener, mock) do
      board.analog_listen(1)
    end
  end

  def test_stop_listener
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [1, :off])

    board.stub(:set_listener, mock) do
      board.stop_listener(1)
    end
  end

  def test_analog_resolution
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [Denko::Message.encode(command: 96, value: 10)])
    mock.expect(:call, nil, [Denko::Message.encode(command: 97, value: 8)])

    board.stub(:write, mock) do
      board.analog_write_resolution = 10
      board.analog_read_resolution = 8
    end
    mock.verify

    assert_raises { board.analog_write_resolution= 17      }
    assert_raises { board.analog_read_resolution= 17       }
    assert_raises { board.analog_write_resolution= "wrong" }
    assert_raises { board.analog_read_resolution= "wrong"  }
  end

  def micro_delay
    aux = pack(:uint16, [1000])
    message = Denko::Message.encode command: 99, aux_message: aux
    mock = Minitest::Mock.new.expect :call, nil, [message]

    board.stub(:write, mock) do
      board.micro_delay(1000)
    end

    assert_raises(ArgumentError) { board.micro_delay(65536)   }
    assert_raises(ArgumentError) { board.micro_delay("wrong") }
  end
end
