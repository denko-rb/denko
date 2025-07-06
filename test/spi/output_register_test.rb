require_relative '../test_helper'

class OutputRegisterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Denko::SPI::Bus.new(board: board)
  end

  def options
    { bus: bus, pin: 9, bytes: 2, spi_frequency: 800000, spi_mode: 2, spi_bit_order: :lsbfirst }
  end

  def part
    @part ||= Denko::SPI::OutputRegister.new(options)
  end

  def led
    @led ||= Denko::LED.new(board: part, pin: 0)
  end

  def test_write
    part.instance_variable_set(:@bytes, 2)
    byte_array = [0b11110000, 0b10101010]

    mock = Minitest::Mock.new.expect :call, nil, [9], write: [0b11110000, 0b10101010], frequency: 800000, mode: 2, bit_order: :lsbfirst
    bus.stub(:transfer, mock) do
      part.instance_variable_set(:@state, byte_array)
      part.write
      sleep 0.010
    end
    mock.verify

    assert_equal part.state, byte_array
  end

  def test_updates_and_writes_state_for_children
    led

    mock = Minitest::Mock.new.expect :call, nil, [9], write: [1, 0], frequency: 800000, mode: 2, bit_order: :lsbfirst
    bus.stub(:transfer, mock) do
      led.on
      sleep 0.050
    end
    mock.verify

    expected_state = [1, 0]
    assert_equal expected_state, part.state
  end

  def test_implements_digital_read_for_children
    led

    mock = Minitest::Mock.new.expect :call, nil, [0]
    part.stub(:digital_read, mock) do
      led.board.digital_read(led.pin)
    end
    mock.verify
  end
end
