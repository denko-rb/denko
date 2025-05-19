require_relative '../test_helper'

class APA102Test < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def bus
    @bus ||= Denko::SPI::Bus.new(board: board)
  end

  def options
    { bus: bus }
  end

  def part
    @part ||= Denko::LED::APA102.new(options)
  end

  def test_added_to_bus_components
    part
    assert bus.components.include?(part)
  end
end
