require_relative '../test_helper'

class PollerComponent
  include Denko::Behaviors::Component
  include Denko::Behaviors::Poller
  def _read; end
end

class PollerTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= PollerComponent.new(board: board, pin: 1)
  end

  def inject(data, wait_for_callbacks = true)
    Thread.new do
      if wait_for_callbacks
        while (!part.callbacks) do; sleep 0.01; end
        while (!part.callbacks[:read]) do; sleep 0.01; end
      end
      loop do
        sleep 0.01
        part.update(data)
        break unless part.callbacks[:read]
      end
    end
  end

  def test_include_callbacks_and_threaded
    assert_includes PollerComponent.ancestors,
                    Denko::Behaviors::Callbacks

    assert_includes PollerComponent.ancestors,
                    Denko::Behaviors::Threaded
  end

  def test_call_stop_before_polling
    mock = Minitest::Mock.new.expect :call, nil
    part.stub(:stop, mock) { part.poll(1) }
    mock.verify
  end

  def test_uses_threaded_loop
    mock = Minitest::Mock.new.expect :call, nil
    part.stub(:threaded_loop, mock) { part.poll(1) }
    mock.verify
  end

  def test_add_and_remove_callback
    callback = Proc.new{}
    part.poll(1, &callback)
    assert_equal part.callbacks[:poll], [callback]
    part.stop
    assert_nil part.callbacks[:poll]
  end

  def test_stop_kills_thread
    mock = Minitest::Mock.new.expect :call, nil
    part.stub(:stop_thread, mock) { part.stop }
    mock.verify
  end
end
