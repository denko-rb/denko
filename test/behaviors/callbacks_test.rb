require_relative '../test_helper'

class CallbackComponent
  include Denko::Behaviors::Component
  include Denko::Behaviors::Callbacks

  def pre_callback_filter(data)
    "denko: #{data}"
  end
end

class CallbackComponentNilFilter
  include Denko::Behaviors::Component
  include Denko::Behaviors::Callbacks

  def pre_callback_filter(data)
    nil
  end
end

class CallbacksTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= CallbackComponent.new(board: board, pin: 1)
  end

  def callback_mutex_is_correct_class
    if (RUBY_ENGINE == "ruby")
      assert_equal Denko::MutexStub, part.instance_variable_get(:@callback_mutex).class
    else
      assert_equal Mutex, part.instance_variable_get(:@callback_mutex).class
    end
  end

  def test_callback_mutex
    callback = Proc.new{}
    lock_mock = Minitest::Mock.new
    2.times {lock_mock.expect(:call, nil)}

    unlock_mock = Minitest::Mock.new
    2.times {unlock_mock.expect(:call, nil)}

    mutex = part.instance_variable_get(:@callback_mutex)
    mutex.stub(:lock, lock_mock) do
      mutex.stub(:unlock, unlock_mock) do
        part.callbacks
        assert_equal({}, part.callbacks)
        part.add_callback(:key, &callback)
        assert part.callbacks[:key]
        part.remove_callbacks(:key)
        assert_equal({}, part.callbacks)
      end
    end
    lock_mock.verify
    unlock_mock.verify
  end

  def test_add_callback
    callback = Proc.new{}
    part.add_callback(&callback)
    assert_equal part.callbacks, {persistent: [callback]}
  end

  def test_add_callback_with_key
    callback = Proc.new{}
    part.add_callback(:key, &callback)
    assert_equal({key: [callback]}, part.callbacks)
  end

  def add_two_callbacks
    @callback1 = Proc.new{}
    @callback2 = Proc.new{}
    part.add_callback(&@callback1)
    part.add_callback(:read, &@callback2)
  end

  def test_remove_callback
    add_two_callbacks
    part.remove_callbacks
    assert_equal({}, part.callbacks)
  end

  def test_remove_callback_with_key
    add_two_callbacks
    part.remove_callbacks(:read)
    assert_nil part.callbacks[:read]
    assert_equal [@callback1], part.callbacks[:persistent]
  end

  def test_update_runs_callbacks_and_removes_read_callbacks
    cb1 = Minitest::Mock.new.expect :call, nil
    cb2 = Minitest::Mock.new.expect :call, nil
    part.add_callback        { cb1.call }
    part.add_callback(:read) { cb2.call }
    part.update("data")
    assert_nil part.callbacks[:read]
    cb1.verify
    cb2.verify
  end

  def test_pre_callback_filter_modifies_data
    cb = Minitest::Mock.new.expect :call, nil, ["denko: value"]
    part.add_callback { |x| cb.call(x) }
    part.update("value")
    cb.verify
  end

  def test_update_state
    part.update("test")
    assert_equal "denko: test", part.state
  end

  def test_no_state_update_when_data_nil
    part.update("test")
    part.update(nil)
    assert_equal "denko: test", part.state
  end

  def test_no_callback_with_data_input_nil
    value = 0
    part.add_callback { value = 1 }
    part.update(nil)
    assert_equal 0, value
  end

  def test_no_callbacks_with_filter_returning_nil
    part2 = CallbackComponentNilFilter.new(board: board, pin: 2)
    value = 0
    part2.add_callback { value = 1 }
    part2.update("anything")
    assert_equal 0, value
  end
end
