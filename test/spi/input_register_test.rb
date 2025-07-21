require_relative '../test_helper'

class InputRegisterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Denko::SPI::Bus.new(board: board)
  end

  def options
    { bus: bus, pin: 9, bytes: 2, spi_frequency: 800000, spi_mode: 2, spi_bit_order: :lsbfirst}
  end

  def part
    @part ||= Denko::SPI::InputRegister.new(options)
  end

  def button
    @button ||= Denko::DigitalIO::Button.new(board: part, pin: 0)
  end

  def test_state_setup
    assert_equal Array.new(16) { false }, part.reading_pins
    assert_equal Array.new(16) { false }, part.listening_pins
    refute_nil   part.callbacks[:board_proxy]
  end

  def test_read
    board.inject_component_update part, [0, 0]

    mock = Minitest::Mock.new.expect :call, nil, [9], read: 2, frequency: 800000, mode: 2, bit_order: :lsbfirst
    bus.stub(:transfer, mock) do
      part.read
    end
    mock.verify
  end

  def test_listen
    mock = Minitest::Mock.new.expect :call, nil, [9], read: 2, frequency: 800000, mode: 2, bit_order: :lsbfirst
    bus.stub(:listen, mock) do
      part.listen
    end
    mock.verify
  end

  def test_stop
    mock = Minitest::Mock.new.expect :call, nil, [9]
    bus.stub(:stop, mock) do
      part.stop
    end
    mock.verify
  end

  def test_updates_child_components
    button
    part.update("1")
    assert button.high?
    part.update("0")
    assert button.low?
  end

  def test_bit_array_conversion_and_state_update
    part.update("127")
    assert_equal [1,1,1,1,1,1,1,0], part.state

    new_part = Denko::SPI::InputRegister.new(options.merge(bytes: 2, pin: 10))
    new_part.update("127,128")
    assert_equal [1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1], new_part.state
  end

  def test_callbacks_get_bit_array
    mock = Minitest::Mock.new.expect :call, nil, [[1,1,1,1,1,1,1,0]]
    part.add_callback do |data|
      mock.call(data)
    end
    part.update("127")
    mock.verify
  end

  def test_read_proxy
    # Disable automatic listener first
    button.stop
    refute button.state

    board.inject_component_update part, [1, 0]
    button.read
    assert_equal 1, button.state
  end

  def test_listener_proxy
    mock = Minitest::Mock.new
    mock.expect :call, nil
    part.stub(:listen, mock) do
      # Tells the register to start listening when it initializees.
      button

      # Should not make a second listen call to the board.
      Denko::DigitalIO::Button.new(board: part, pin: 1)
    end
    mock.verify

    expected_array = Array.new(options[:bytes] * 8) { false }
    expected_array[0] = true
    expected_array[1] = true

    # Should be listening to the lowest 2 bits now.
    assert_equal expected_array, part.instance_variable_get(:@listening_pins)
  end

  def test_stop_listener_proxy
    button

    # Calling stop on a child part, when only it is listening, should call stop on the register too.
    mock = Minitest::Mock.new.expect :call, nil
    part.stub(:stop, mock) do
      button.stop
    end
    mock.verify

    # Check listener tracking is correct.
    assert_equal Array.new(options[:bytes] * 8) { false }, part.instance_variable_get(:@listening_pins)
    refute part.any_listening
  end

  def test_gets_reads_through_select
    mock = Minitest::Mock.new.expect :call, nil, ["127,255"]
    part.stub(:update, mock) do
      board.update("#{part.select.pin}:127,255")
    end
    mock.verify
  end
end
