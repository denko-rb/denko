require_relative '../test_helper'

class PinlessComponentMock
  def stop
  end
end

class SinglePinComponentMock
  def pin
    1
  end
end

class MultiPinComponentMock
  def pin
    {a: 1, b: 2}
  end
end

class SubcomponentsTest < Minitest::Test
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Denko::Board.new(connection)
  end

  def test_add_remove_pinless
    pinless = PinlessComponentMock.new

    board.add_component(pinless)
    assert_equal [pinless], board.components
    assert_empty board.single_pin_components

    board.remove_component(pinless)
    assert_empty board.components
  end

  def test_add_remove_single_pin
    single_pin = SinglePinComponentMock.new

    board.add_component(single_pin)
    test_hash = {1 => single_pin}
    assert_equal [single_pin], board.components
    assert_equal test_hash,    board.single_pin_components

    board.remove_component(single_pin)
    assert_empty board.components
    refute board.single_pin_components[1]
  end

  def test_add_remove_multi_pin
    multi_pin = MultiPinComponentMock.new

    board.add_component(multi_pin)
    assert_equal [multi_pin], board.components
    assert_empty board.single_pin_components

    board.remove_component(multi_pin)
    assert_empty board.components
  end

  def test_calls_stop_on_remove
    pinless = PinlessComponentMock.new
    board.add_component(pinless)

    mock = Minitest::Mock.new.expect(:call, nil)
    pinless.stub(:stop, mock) do
      board.remove_component(pinless)
    end

    mock.verify
  end

  def test_disallows_duplicate_hw_i2c_buses
    i2c0 = Denko::I2C::Bus.new(board: board, pin: 0)
    assert_raises { Denko::I2C::Bus.new(board: board) }
  end

  def test_hw_i2c_buses_add_and_remove_properly
    i2c0 = Denko::I2C::Bus.new(board: board, i2c_index: 0)
    i2c1 = Denko::I2C::Bus.new(board: board, i2c_index: 1)
    assert_equal [i2c0, i2c1], board.components

    # Have the right hash keys.
    assert_equal i2c0, board.hw_i2c_comps[0]
    assert_equal i2c1, board.hw_i2c_comps[1]

    # Get removed correctly.
    board.remove_component(i2c0)
    hash = { 1 => i2c1 }
    assert_equal hash, board.hw_i2c_comps
  end
end
