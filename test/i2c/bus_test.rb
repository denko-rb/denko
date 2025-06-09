require_relative '../test_helper'

class I2CPeripheralBase
  include Denko::I2C::Peripheral
end

class I2CBusTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::I2C::Bus.new(board: board)
  end

  def peripheral
    @peripheral ||= I2CPeripheralBase.new(bus: part, address: 0x30)
  end

  def test_initialize
    assert_equal part.found_devices, []
    assert_equal 0, part.i2c_index
    refute_nil part.callbacks[:bus_controller]

    part2 = Denko::I2C::Bus.new(board: board, index: 10)
    assert_equal 10, part2.i2c_index

    part3 = Denko::I2C::Bus.new(board: board, i2c_index: 11)
    assert_equal 11, part3.i2c_index
  end

  def test_search
    # Reject 0s created by leading and trailing colons.
    board.inject_read_for_i2c(0, ":48:50:")

    mock = Minitest::Mock.new.expect :call, nil, [0]
    board.stub(:i2c_search, mock) do
      part.search
    end
    mock.verify

    assert_equal part.found_devices, [0x30, 0x32]
  end

  def test_search_with_array_response
    board.inject_component_update(part, [0, 0x30, 0x32])
    part.search
    assert_equal [0x30, 0x32], part.found_devices
  end

  def test_search_empty_results
    board.inject_read_for_i2c(0, ":")
    part.search
    assert_equal [], part.found_devices
  end

  def test_write
    mock = Minitest::Mock.new.expect :call, nil, [0, 0x30, [0x01, 0x02], 100000, false]
    board.stub(:i2c_write, mock) do
      part.write 0x30, [0x01, 0x02]
    end
    mock.verify
  end

  def test__read_string
    board.inject_read_for_i2c(0, "48-255,0,255,0,255,0")

    mock = Minitest::Mock.new.expect :call, nil, [0, 0x32, 0x03, 6, 100000, false]
    board.stub(:i2c_read, mock) do
      part.read 0x32, 0x03, 6
    end
    mock.verify
  end

  def test__read_array
    board.inject_read_for_i2c(0, [48,255,0,255,0,255,0])

    mock = Minitest::Mock.new.expect :call, nil, [0, 0x32, 0x03, 6, 100000, false]
    board.stub(:i2c_read, mock) do
      part.read 0x32, 0x03, 6
    end
    mock.verify
  end

  def test_read_without_register
    board.inject_component_update(part, "48-255,127")

    mock = Minitest::Mock.new.expect :call, nil, [0, 0x30, nil, 2, 100000, false]
    board.stub(:i2c_read, mock) do
      part.read 0x30, nil, 2
    end
    mock.verify
  end

  def test_updates_peripherals
    mock = Minitest::Mock.new.expect :call, nil, [[255, 127]]

    peripheral.stub(:update, mock) do
      part.send(:update, "48-255,127")
      part.send(:update, "50-128,0")
    end
    mock.verify
  end

  def test_updates_peripherals_with_array_data
    mock = Minitest::Mock.new.expect :call, nil, [[255, 127]]

    peripheral.stub(:update, mock) do
      part.send(:update, [0x30, 255, 127])
      part.send(:update, [0x32, 128, 0])
    end
    mock.verify
  end

  def test_ignores_updates_for_non_matching_addresses
    mock = Minitest::Mock.new
    # Mock should not receive any calls

    peripheral.stub(:update, mock) do
      part.send(:update, "49-255,127")  # Different address
    end
    mock.verify
  end

  def test_handles_empty_data_gracefully
    part.send(:update, "48-")
    part.send(:update, "48")
  end

  def test_handles_malformed_string_data
    part.send(:update, "invalid-data")
    part.send(:update, "")
    part.send(:update, nil)
  end

  def test_same_address_fails
    peripheral
    assert_raises { I2CPeripheralBase.new(bus: part, address: 0x30) }
  end

  # Should split up Subcomponents behavior and test there?
  def test_component_management
    count = part.components.length
    new_peripheral = I2CPeripheralBase.new(bus: part, address: 0x40)

    assert_equal count+1, part.components.length
    assert_includes part.components, new_peripheral
  end

  def test_found_devices_not_writable
    assert_raises { part.found_devices = nil }
  end
end
