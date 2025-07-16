require_relative '../test_helper'

class MultiPinComponent
  include Denko::Behaviors::MultiPin

  def initialize_pins
    require_pin :one
    proxy_pin   :two,         Denko::DigitalIO::Output
    proxy_pin   :maybe,       Denko::DigitalIO::Input,  optional: true
    proxy_pin   :other_board, Denko::DigitalIO::Output, board: params[:board2], optional: true
  end
end

class MultiPinTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def board2
    @board2 ||= BoardMock.new
  end

  def part
    @part ||= MultiPinComponent.new board: board,
                                    board2: board2,
                                    pins: { one: 9, two: 10, maybe: 11, other_board: 13 }
  end

  def test_validate_pins
    assert_raises(ArgumentError) do
      MultiPinComponent.new board: board, pins: { one: 9, maybe: 11 }
    end
    assert_raises(ArgumentError) do
      MultiPinComponent.new board: board, pins: { two: 10, maybe: 11 }
    end
    MultiPinComponent.new board: board, pins: { one: 9, two:10 }
  end

  def test_has_nil_pin
    assert_nil part.pin
  end

  def test_build_proxies
    assert_equal Denko::DigitalIO::Output, part.proxies[:two].class
    assert_equal Denko::DigitalIO::Input, part.proxies[:maybe].class
  end

  def test_build_proxy_on_other_board
    assert_equal board2, part.proxies[:other_board].board
  end

  def attr_reader_exists_for_optional_pins
    part = MultiPinComponent.new board: board, pins: { one: 9, two:10 }
    assert_nil part.maybe
  end

  def test_proxy_reader_methods
    assert_equal part.proxies[:two], part.two
    assert_equal part.proxies[:maybe], part.maybe
  end

  def test_pins_mapped_correctly
    assert_equal 10, part.two.pin
    assert_equal 11, part.maybe.pin
  end

  def test_proxy_states
    part.two.high
    assert_equal({two: board.high, maybe: nil, other_board: nil}, part.proxy_states)

    part2 = MultiPinComponent.new board: board, pins: { one: 'A1', two:12 }
    part2.two.low
    assert_equal({two: board.low}, part2.proxy_states)
  end

  def test_required_but_not_proxied_pin_conversion
    part = MultiPinComponent.new board: board, pins: { one: 'A0', two:10 }
    assert_equal 14, part.pins[:one]
  end
end
