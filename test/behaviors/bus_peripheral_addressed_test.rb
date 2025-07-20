require_relative '../test_helper'

class AddressedBus
  include Denko::Behaviors::Component
  include Denko::Behaviors::BusControllerAddressed
end

class AddressedPeripheral
  include Denko::Behaviors::Component
  include Denko::Behaviors::BusPeripheralAddressed
end

class BusPeripheralAddressedTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= AddressedBus.new(board: board)
  end
  
  def part
    @part ||= AddressedPeripheral.new(bus: bus, address: 0x22)
  end
  
  def test_initialize
    assert_equal part.board, bus
    assert_equal part.address, 0x22
  end
  
  def test_requires_address
    assert_raises(ArgumentError) { AddressedPeripheral.new(bus: bus) }
  end
  
  def test_can_use_bus_atomically   
    mock = Minitest::Mock.new
    1.times {mock.expect(:call, nil)}
    
    bus.mutex.stub(:synchronize, mock) do
      part.atomically { true; false; }
    end
    mock.verify
  end
end
