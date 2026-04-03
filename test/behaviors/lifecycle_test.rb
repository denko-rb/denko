require_relative '../test_helper'

class Parent
  include Denko::Behaviors::Component
  include Denko::Behaviors::Lifecycle

  attr_reader :before_flag, :after_flag, :before_order, :after_order

  BEFORE_CALLBACK = proc {
    @before_flag = true
    @before_order ||= []
    @before_order << :parent_before
  }
  AFTER_CALLBACK = proc {
    @after_flag = true
    @after_order ||= []
    @after_order << :parent_after
  }

  before_initialize(&BEFORE_CALLBACK)
  after_initialize(&AFTER_CALLBACK)
end

class Child < Parent
  include Denko::Behaviors::Lifecycle

  before_initialize do
    @before_order ||= []
    @before_order << :child_before
  end
  after_initialize do
    @after_order ||= []
    @after_order << :child_after
  end
end

class ChildNoInclude < Parent
end

class MultiCallback
  include Denko::Behaviors::Component
  include Denko::Behaviors::Lifecycle

  attr_reader :order

  BEFORE_FIRST = proc {
    @order ||= []
    @order << :before_first
  }
  BEFORE_SECOND = proc {
    @order ||= []
    @order << :before_second
  }
  AFTER_FIRST = proc {
    @order ||= []
    @order << :after_first
  }
  AFTER_SECOND = proc {
    @order ||= []
    @order << :after_second
  }

  before_initialize(&BEFORE_FIRST)
  before_initialize(&BEFORE_SECOND)
  after_initialize(&AFTER_FIRST)
  after_initialize(&AFTER_SECOND)
end

class ParamsAccess
  include Denko::Behaviors::Component
  include Denko::Behaviors::Lifecycle

  attr_reader :extracted, :processed

  before_initialize { @extracted = params[:value] }
  after_initialize { @processed = @extracted * 2 }
end

class ExclusiveFirst
  include Denko::Behaviors::Component
  include Denko::Behaviors::Lifecycle
  before_initialize {}
end

class ExclusiveSecond
  include Denko::Behaviors::Component
  include Denko::Behaviors::Lifecycle
  before_initialize {}
end

class LifecycleTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def test_before_initialize_callback_runs
    cbs = Parent.instance_variable_get(:@before_initialize_cbs)
    assert_equal [Parent::BEFORE_CALLBACK], cbs

    component = Parent.new(board: board)
    assert component.before_flag
  end

  def test_after_initialize_callback_runs
    cbs = Parent.instance_variable_get(:@after_initialize_cbs)
    assert_equal [Parent::AFTER_CALLBACK], cbs

    component = Parent.new(board: board)
    assert component.after_flag
  end

  def test_callbacks_see_params
    component = ParamsAccess.new(board: board, value: 5)
    assert_equal 5, component.extracted
    assert_equal 10, component.processed
  end

  def test_before_callbacks_run_bottom_up
    component = Child.new(board: board)
    assert_equal %i[child_before parent_before], component.before_order
  end

  def test_after_callbacks_run_top_down
    component = Child.new(board: board)
    assert_equal %i[parent_after child_after], component.after_order
  end

  def test_callbacks_run_without_lifecycle_include
    component = ChildNoInclude.new(board: board)
    assert component.before_flag
    assert component.after_flag
  end

  def test_multiple_callbacks_same_class
    before_cbs = MultiCallback.instance_variable_get(:@before_initialize_cbs)
    assert_equal [MultiCallback::BEFORE_FIRST, MultiCallback::BEFORE_SECOND], before_cbs

    after_cbs = MultiCallback.instance_variable_get(:@after_initialize_cbs)
    assert_equal [MultiCallback::AFTER_FIRST, MultiCallback::AFTER_SECOND], after_cbs

    component = MultiCallback.new(board: board)

    expected = %i[before_first before_second after_first after_second]
    assert_equal expected, component.order
  end

  def test_callbacks_not_shared_between_classes
    procs1 = ExclusiveFirst.send(:before_initialize) {}
    procs2 = ExclusiveSecond.send(:before_initialize) {}

    refute_same procs1, procs2
    refute_same procs1.first, procs2.first
  end
end
