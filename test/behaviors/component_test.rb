require_relative '../test_helper'

class BaseComponent
  include Denko::Behaviors::Component
end

class ComponentTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= BaseComponent.new(board: board)
  end

  def test_requires_board
    assert_raises(ArgumentError) { BaseComponent.new }
  end

  def test_registers_with_board
    assert_equal board.components, [part]
  end

  def test_unregisters_with_board
    part.send(:unregister)
    assert_equal board.components, []
  end

  def test_start_with_nil_state
    assert_nil BaseComponent.new(board: board).state
  end

  def test_state_mutex_is_correct_class
    if (RUBY_ENGINE == "ruby")
      assert_equal Denko::MutexStub, part.state_mutex.class
    else
      assert_equal Mutex, part.state_mutex.class
    end
  end

  def test_sets_and_gets_state
    part.send(:state=, 10)
    assert_equal part.state, 10
  end

  def test_state_through_mutex
    mock = Minitest::Mock.new
    2.times {mock.expect(:call, nil)}

    part.state_mutex.stub(:synchronize, mock) do
      part.state
      part.send(:state=, nil)
    end
    mock.verify
  end

  def test_micro_delay
    mock = Minitest::Mock.new.expect :call, nil, [1000]

    board.stub(:micro_delay, mock) do
      part.micro_delay(1000)
    end
  end
end
