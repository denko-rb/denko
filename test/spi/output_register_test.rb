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
    part
    mock = Minitest::Mock.new.expect :call, nil, [9], write: [255,127], frequency: 800000, mode: 2, bit_order: :lsbfirst
    bus.stub(:transfer, mock) do
      arr = Array.new(16) { 1 }; arr[7] = 0
      part.instance_variable_set(:@state, arr)
      part.write
    end
    mock.verify
  end

  def test_updates_and_writes_state_for_children
    led

    mock = Minitest::Mock.new.expect :call, nil, [9], write: [0, 1], frequency: 800000, mode: 2, bit_order: :lsbfirst
    bus.stub(:transfer, mock) do
      led.on
      sleep 0.050
    end
    mock.verify

    expected_state = Array.new(options[:bytes] * 8) { |i| 0 }
    expected_state[0] = 1

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

  def test_bit_and_byte_orders_correct
    part.instance_variable_set(:@bytes, 2)
    bit_array = "0101010100001111".split("")

    mock = Minitest::Mock.new.expect :call, nil, [9], write: [0b11110000, 0b10101010], frequency: 800000, mode: 2, bit_order: :lsbfirst
    bus.stub(:transfer, mock) do
      part.instance_variable_set(:@state, bit_array)
      part.write
      sleep 0.002
    end
    mock.verify

    assert_equal part.state, bit_array
  end
end
