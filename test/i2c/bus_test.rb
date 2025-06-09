require_relative '../test_helper'

class I2CPeripheralBase
  include Denko::I2C::Peripheral
end

class I2CBusTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Denko::I2C::Bus.new(board: board)
  end

  def peripheral
    @peripheral ||= I2CPeripheralBase.new(bus: bus, address: 0x30)
  end

  def test_initialize
    assert_equal [],  bus.found_devices
    assert_equal 0,   bus.i2c_index
    refute_nil bus.callbacks[:bus_controller]

    bus2 = Denko::I2C::Bus.new(board: board, index: 10)
    assert_equal 10, bus2.i2c_index
  end

  def test_search_result_string
    # Reject 0s created by leading and trailing colons.
    board.inject_component_update(bus, ":48:50:")
    bus.search
    assert_equal [0x30, 0x32], bus.found_devices
  end

  def test_search_resul_array
    board.inject_component_update(bus, [0, 0x30, 0x32])
    bus.search
    assert_equal [0x30, 0x32], bus.found_devices
  end

  def test_search_result_empty
    board.inject_component_update(bus, ":")
    bus.search
    assert_equal [], bus.found_devices
  end

  def test_write
    mock = Minitest::Mock.new.expect :call, nil, [0, 0x30, [0x01, 0x02], 100000, false]

    board.stub(:i2c_write, mock) do
      bus.write 0x30, [0x01, 0x02]
    end
    mock.verify
  end

  def test_read_string
    board.inject_component_update(bus, "48-255,0,255,0,255,0")
    mock = Minitest::Mock.new.expect :call, nil, [0, 0x32, 0x03, 6, 100000, false]

    board.stub(:i2c_read, mock) do
      bus.read 0x32, 0x03, 6
    end
    mock.verify
  end

  def test_read_array
    board.inject_component_update(bus, [48,255,0,255,0,255,0])
    mock = Minitest::Mock.new.expect :call, nil, [0, 0x32, 0x03, 6, 100000, false]

    board.stub(:i2c_read, mock) do
      bus.read 0x32, 0x03, 6
    end
    mock.verify
  end

  def test_read_without_register
    board.inject_component_update(bus, "48-255,127")
    mock = Minitest::Mock.new.expect :call, nil, [0, 0x30, nil, 2, 100000, false]

    board.stub(:i2c_read, mock) do
      bus.read 0x30, nil, 2
    end
    mock.verify
  end

  def test_updates_peripherals_string
    mock = Minitest::Mock.new.expect :call, nil, [[255, 127]]

    peripheral.stub(:update, mock) do
      bus.send(:update, "48-255,127")
      bus.send(:update, "50-128,0")
    end
    mock.verify
  end

  def test_updates_peripherals_array
    mock = Minitest::Mock.new.expect :call, nil, [[255, 127]]

    peripheral.stub(:update, mock) do
      bus.send(:update, [0x30, 255, 127])
      bus.send(:update, [0x32, 128, 0])
    end
    mock.verify
  end

  def test_ignores_updates_for_non_matching_addresses
    # mock should not receive any calls
    mock = Minitest::Mock.new

    peripheral.stub(:update, mock) do
      bus.send(:update, "49-255,127")
    end
    mock.verify
  end

  def test_handles_empty_data_gracefully
    bus.send(:update, "48-")
    bus.send(:update, "48")
  end

  def test_handles_malformed_string_data
    bus.send(:update, "invalid-data")
    bus.send(:update, "")
    bus.send(:update, nil)
  end

  def test_same_address_fails
    peripheral
    assert_raises { I2CPeripheralBase.new(bus: bus, address: 0x30) }
  end

  # Should split up Subcomponents behavior and test there?
  def test_component_management
    count = bus.components.length
    new_peripheral = I2CPeripheralBase.new(bus: bus, address: 0x40)

    assert_equal count+1, bus.components.length
    assert_includes bus.components, new_peripheral
  end

  def test_found_devices_not_writable
    assert_raises { bus.found_devices = nil }
  end
end
