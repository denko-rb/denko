require_relative '../test_helper'

class RotaryEncoderTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::DigitalIO::RotaryEncoder.new board: board, pins: {data:3, clock: 4}
  end

  def test_sets_steps_per_revolution
    assert_equal 30,      part.steps_per_revolution
    assert_equal 12.to_f, part.instance_variable_get(:@degrees_per_step)
  end
  
  def test_resets_on_initialize
    assert_equal part.state, {steps: 0, angle: 0}
  end
  
  def test_calls_listen_on_both_pins_with_given_divider
    clock_mock = Minitest::Mock.new.expect(:call, nil, [1])
    clock_mock.expect(:call, nil, [2])
    data_mock = Minitest::Mock.new.expect(:call, nil, [1])
    data_mock.expect(:call, nil, [2])
    
    part.clock.stub(:listen, clock_mock) do
      part.data.stub(:listen, data_mock) do
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
    refute_empty part.clock.callbacks
    assert_empty part.data.callbacks
        
    part2 = Denko::DigitalIO::RotaryEncoder.new board: board, pins: {data:6, clock: 5}
    
    refute_empty part2.data.callbacks
    assert_empty part2.clock.callbacks
  end
  
  def test_goes_the_right_direction
    part.data.send(:update, 1)
    part.clock.send(:update, 1)
    assert_equal({ steps: -1, angle: 348.0 }, part.state)
    
    part.reset
    
    part.data.send(:update, 1)
    part.clock.send(:update, 0)
    assert_equal({ steps: 1, angle: 12.0 }, part.state)
  end

  def test_reverse
    part.reverse
    assert part.reversed

    part.data.send(:update, 1)
    part.clock.send(:update, 1)
    assert_equal({ steps: 1, angle: 12.0 }, part.state)
  end

  def test_swapped_pins
    part2 = Denko::DigitalIO::RotaryEncoder.new board: board, pins: {data:4, clock: 3}

    part2.clock.send(:update, 1)
    part2.data.send(:update, 1)
    assert_equal({ steps: 1, angle: 12.0 }, part2.state)
  end
  
  def test_callback_prefilter
    part.data.send(:update, 1)
    part.clock.send(:update, 0)
    callback_value = nil
    part.add_callback do |value|
      callback_value = value.dup
    end
    part.data.send(:update, 1)
    part.clock.send(:update, 0)
    
    assert_equal({change: 1, steps: 2, angle: 24.0}, callback_value)
  end
  
  def test_update_state_removes_change
    part.data.send(:update, 1)
    part.clock.send(:update, 1)
    assert_nil part.state[:change]
  end
end
