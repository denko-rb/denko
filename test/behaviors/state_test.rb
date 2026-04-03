require_relative '../test_helper'

class StateComponent
  include Denko::Behaviors::State
  include Denko::Behaviors::Component
end

class StateTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def component
    @component ||= StateComponent.new(board: board)
  end

  def test_state_is_nil_by_default
    assert_nil component.state
  end

  def test_state_can_be_set
    component.update_state(42)
    assert_equal 42, component.state
  end

  def test_update_state_overwrites_previous_value
    component.update_state(1)
    assert_equal 1, component.state

    component.update_state(2)
    assert_equal 2, component.state
  end

  def test_state_with_different_instances_are_independent
    component1 = StateComponent.new(board: board)
    component2 = StateComponent.new(board: board)

    component1.update_state(1)
    component2.update_state(2)

    assert_equal 1, component1.state
    assert_equal 2, component2.state
  end
end
