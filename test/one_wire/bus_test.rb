require_relative '../test_helper'

class OneWireBusTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    return @part if @part
    # Respond with disabled parasite power.
    board.inject_read_for_pin(1, "1")
    @part ||= Denko::OneWire::Bus.new(board: board, pin: 1)
  end

  def test_initialize
    board.inject_read_for_pin(2, "0")
    bus2 = Denko::OneWire::Bus.new(board: board, pin: 2)
    assert bus2.parasite_power
  end

  def test_read_power_supply
    board.inject_component_update(part, "0")

    lock_mock = Minitest::Mock.new.expect(:call, nil)
    unlock_mock = Minitest::Mock.new.expect(:call, nil)

    part.mutex.stub(:lock, lock_mock) do
      part.mutex.stub(:unlock, unlock_mock) do
        part.read_power_supply
      end
    end

    lock_mock.verify
    unlock_mock.verify
    assert part.parasite_power

    board.inject_component_update(part, "1")
    part.read_power_supply
    refute part.parasite_power
  end

  def test_read_power_supply_sends_board_commands
    board_mock = Minitest::Mock.new
    board_mock.expect(:set_pin_mode, nil, [part.pin, :output])
    board_mock.expect(:low, 0)
    board_mock.expect(:digital_write,  nil, [part.pin, 0])
    board_mock.expect(:one_wire_reset, nil, [part.pin, false])
    board_mock.expect(:one_wire_write, nil, [part.pin, false, [0xCC, 0xB4]])

    # Stub the parasite power response from the board.
    read_mock = Minitest::Mock.new
    read_mock.expect(:call, 0, [1])

    part.stub(:board, board_mock) do
      part.stub(:read, read_mock) do
        part.read_power_supply
      end
    end

    board_mock.verify
    read_mock.verify
    assert part.parasite_power
  end

  def test_device_present_in_mutex
    # part.device_present calls #reset which expects a response.
    board.inject_component_update(part, "1")

    lock_mock = Minitest::Mock.new.expect(:call, nil)
    unlock_mock = Minitest::Mock.new.expect(:call, nil)

    part.mutex.stub(:lock, lock_mock) do
      part.mutex.stub(:unlock, unlock_mock) do
        part.device_present
      end
    end

    lock_mock.verify
    unlock_mock.verify
  end

  def test_set_device_present
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [true])
    mock.expect(:call, nil, [true])

    part.stub(:reset, mock) do
      # Give 0 for first reading, device present
      board.inject_component_update(part, "0")
      assert part.device_present

      # Give 1 for second reading, no device
      board.inject_component_update(part, "1")
      refute part.device_present
    end
    mock.verify
  end

  def test_pre_callback_filter
    assert_equal [255, 180, 120], part.pre_callback_filter("255,180,120")
    assert_equal 127,             part.pre_callback_filter("127")
    assert_equal [123, 111, 187], part.pre_callback_filter([123,111,187])
  end

  def test_reset
    part
    mock = Minitest::Mock.new
    mock.expect :call, nil, [1, true]
    mock.expect :call, nil, [1, false]

    board.stub(:one_wire_reset, mock) do
      part.reset(true)
      part.reset
    end
    mock.verify
  end

  def test_write
    part
    mock = Minitest::Mock.new
    mock.expect :call, nil, [1, true,  [255, 177, 0x44]]
    mock.expect :call, nil, [1, true,  [255, 177, 0x48]]
    mock.expect :call, nil, [1, false, [255, 177, 0x55]]
    mock.expect :call, nil, [1, false, [255, 177, 0x44]]

    board.stub(:one_wire_write, mock) do
      # Parasite power on and parasite power functions.
      part.instance_variable_set(:@parasite_power, true)
      part.write [255, 177, 0x44]
      part.write [255, 177, 0x48]

      # Parasite power on and not parasite power functions.
      part.write [255, 177, 0x55]

      # Parasite power off and would-be parasite power function.
      part.instance_variable_set(:@parasite_power, false)
      part.write [255, 177, 0x44]
    end
    mock.verify
  end
end
