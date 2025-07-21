require_relative '../test_helper'

class ReaderComponent
  include Denko::Behaviors::Component
  include Denko::Behaviors::Reader
  def _read; end
end

class ReaderTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= ReaderComponent.new(board: board, pin: 1)
  end

  def test_include_callbacks
    assert_includes ReaderComponent.ancestors,
                    Denko::Behaviors::Callbacks
  end

  def test_read_once
    mock = Minitest::Mock.new.expect :call, nil
    board.inject_component_update(part, 25)

    part.stub(:_read, mock) do
      part.read
    end
    mock.verify

    assert_equal 25, part.instance_variable_get(:@read_result)
  end

  def test_return_value
    board.inject_component_update(part, 42)
    assert_equal 42, part.read
  end

  def test_read_using_with_lambda
    board.inject_component_update(part, 1)
    reader = Minitest::Mock.new.expect :call, nil
    part.read_using -> { reader.call }
    reader.verify
  end

  def test_read_using_with_method
    board.inject_component_update(part, 1)
    reader = Minitest::Mock.new.expect :call, nil
    part.read_using reader
    reader.verify
  end

  def test_add_run_remove_callback
    cb = Minitest::Mock.new.expect :call, nil
    board.inject_component_update(part, 1)
    part.read { cb.call }
    assert_nil part.callbacks[:read]
    cb.verify
  end
end
