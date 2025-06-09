require_relative '../test_helper'

class OneWirePeripheralTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    return @bus if @bus
    # Respond with disabled parasite power.
    board.inject_read_for_pin(1, "1")
    @bus ||= Denko::OneWire::Bus.new(board: board, pin: 1)
  end

  def part
    @part ||= Denko::OneWire::Peripheral.new(bus: bus, address: 0xFFFFFFFFFFFFFFFF)
  end

  def test_requires_address
    assert_raises(ArgumentError) { Denko::OneWire::Peripheral.new(bus: bus) }
  end

  def test_atomically_locks_the_bus_mutex
    mock = Minitest::Mock.new.expect(:synchronize, nil)
    bus.stub(:mutex, mock) do
      part.atomically {}
    end
    mock.verify
  end

  def test_atomically_calls_the_block_once
    mock = Minitest::Mock.new.expect(:call, nil)
    part.atomically { mock.call }
    mock.verify
  end

  def test_match_calls_reset
    mock = Minitest::Mock.new.expect(:call, nil)
    bus.stub(:reset, mock) do
      part.match
    end
    mock.verify
  end

  def test_match_skips_rom_if_alone
    mock = Minitest::Mock.new.expect(:call, nil, [0xCC])
    bus.stub(:write, mock) do
      part.match
    end
    mock.verify
  end

  def test_match_matches_rom_if_not_alone
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [0x55])
    mock.expect(:call, nil, [[255,255,255,255,255,255,255,255]])
    bus.instance_variable_set(:@found_devices, [1,2])
    bus.stub(:write, mock) do
      part.match
    end
    mock.verify
  end

  def test_copy_scratch_is_atomic
    mock = Minitest::Mock.new.expect(:call, nil)
    part.stub(:atomically, mock) { part.copy_scratch }
    mock.verify
  end

  def test_copy_scratch_matches_first
    mock = Minitest::Mock.new.expect(:call, nil)
    part.stub(:match, mock) { part.copy_scratch }
    mock.verify
  end

  def test_copy_scratch_sends_the_command
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [0xCC])
    mock.expect(:call, nil, [0x48])
    bus.stub(:write, mock) { part.copy_scratch }
    mock.verify
  end

  def test_copy_scratch_resets_after_command_if_parasite_power
    mock = Minitest::Mock.new.expect(:call, nil).expect(:call, nil)
    bus.stub(:parasite_power, true) do
      bus.stub(:reset, mock) { part.copy_scratch }
    end
    mock.verify
  end

  def test_read_scratch_is_atomic
    board.inject_component_update(bus, "255,255,255,255,255,255,255,255")

    mock = Minitest::Mock.new.expect(:call, nil)
    part.stub(:atomically, mock) { part.read_scratch(9) }
    mock.verify
  end

  def test_read_scratch_matches_first
    board.inject_component_update(bus, "255,255,255,255,255,255,255,255")

    mock = Minitest::Mock.new.expect(:call, nil)
    part.stub(:match, mock) { part.read_scratch(9) }
    mock.verify
  end

  def test_read_scratch_sends_the_command
    board.inject_component_update(bus, "255,255,255,255,255,255,255,255")

    mock = Minitest::Mock.new
    mock.expect(:call, nil, [0xCC])
    mock.expect(:call, nil, [0xBE])
    bus.stub(:write, mock) { part.read_scratch(9) }
    mock.verify
  end

  def test_read_scratch_reads_bytes_from_bus
    board.inject_component_update(bus, "255,255,255,255,255,255,255,255")

    mock = Minitest::Mock.new.expect(:call, nil, [9])
    bus.stub(:read, mock) { part.read_scratch(9) }
    mock.verify
  end

  def test_write_scratch_is_atomic
    mock = Minitest::Mock.new.expect(:call, nil)
    part.stub(:atomically, mock) { part.write_scratch(1) }
    mock.verify
  end

  def test_write_scratch_matches_first
    mock = Minitest::Mock.new.expect(:call, nil)
    part.stub(:match, mock) { part.write_scratch(1) }
    mock.verify
  end

  def test_write_scratch_sends_the_command_and_data
    mock = Minitest::Mock.new
    mock.expect(:call, nil, [0xCC])
    mock.expect(:call, nil, [0x4E])
    mock.expect(:call, nil, [1,2,3])
    bus.stub(:write, mock) { part.write_scratch(1, 2, 3) }
    mock.verify
  end
end
