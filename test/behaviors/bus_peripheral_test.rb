require_relative '../test_helper'

class NoAddressController
  include Denko::Behaviors::Component
  include Denko::Behaviors::BusController
end

class NoAddressPeripheral
  include Denko::Behaviors::Component
  include Denko::Behaviors::BusPeripheral
end

class BusPeripheralTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= NoAddressController.new(board: board)
  end
  
  def part
    @part ||= NoAddressPeripheral.new(bus: bus, address: 0x22)
  end
  
  def test_initialize
    assert_equal part.board, bus
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
