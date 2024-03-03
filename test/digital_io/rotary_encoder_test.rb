require_relative '../test_helper'

class RotaryEncoderTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::DigitalIO::RotaryEncoder.new board: board, pins: {b: 3, a: 4}
  end

  def test_alternate_pin_names
    short = Denko::DigitalIO::RotaryEncoder.new board: board, pins: {dt: 3, clk: 4}
    assert_equal 3, short.b.pin
    assert_equal 4, short.a.pin

    long = Denko::DigitalIO::RotaryEncoder.new board: board, pins: {data: 5, clock: 6}
    assert_equal 5, long.b.pin
    assert_equal 6, long.a.pin
  end

  def test_sets_steps_per_revolution
    assert_equal 30,      part.steps_per_revolution
    assert_equal 12.to_f, part.instance_variable_get(:@degrees_per_step)
  end
  
  def test_resets_on_initialize
    assert_equal({steps: 0, angle: 0}, part.state)
  end
  
  def test_calls_listen_on_both_pins_with_given_divider
    a_mock = Minitest::Mock.new.expect(:call, nil, [1])
    a_mock.expect(:call, nil, [2])
    b_mock = Minitest::Mock.new.expect(:call, nil, [1])
    b_mock.expect(:call, nil, [2])
    
    part.a.stub(:listen, a_mock) do
      part.b.stub(:listen, b_mock) do
        part.send(:after_initialize)
        part.send(:after_initialize, divider: 2)
      end
    end
  end
  
  def test_observes_on_initialize
    mock = Minitest::Mock.new.expect(:call, nil)
    part.stub(:observe_pins, mock) do
      part.send(:after_initialize)
    end
  end
  
  def test_observes_the_right_pin
    refute_empty part.a.callbacks
    assert_empty part.b.callbacks
        
    part2 = Denko::DigitalIO::RotaryEncoder.new board: board, pins: {b: 6, a: 5}
    
    refute_empty part2.b.callbacks
    assert_empty part2.a.callbacks
  end
  
  def test_goes_the_right_direction
    part.b.send(:update, 1)
    part.a.send(:update, 1)
    assert_equal({ steps: -1, angle: 348.0 }, part.state)
    
    part.reset
    
    part.b.send(:update, 1)
    part.a.send(:update, 0)
    assert_equal({ steps: 1, angle: 12.0 }, part.state)
  end

  def test_reverse
    part.reverse
    assert part.reversed

    part.b.send(:update, 1)
    part.a.send(:update, 1)
    assert_equal({ steps: 1, angle: 12.0 }, part.state)
  end

  def test_swapped_pins
    part2 = Denko::DigitalIO::RotaryEncoder.new board: board, pins: {b: 4, a: 3}

    part2.a.send(:update, 1)
    part2.b.send(:update, 1)
    assert_equal({ steps: 1, angle: 12.0 }, part2.state)
  end
  
  def test_callback_prefilter
    part.b.send(:update, 1)
    part.a.send(:update, 0)
    callback_value = nil
    part.add_callback do |value|
      callback_value = value.dup
    end
    part.b.send(:update, 1)
    part.a.send(:update, 0)
    
    assert_equal({change: 1, steps: 2, angle: 24.0}, callback_value)
  end
  
  def test_update_state_removes_change
    part.b.send(:update, 1)
    part.a.send(:update, 1)
    assert_nil part.state[:change]
  end
end
