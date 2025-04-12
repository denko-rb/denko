require_relative '../test_helper'

class A3967MotorTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::Motor::A3967.new board: board,
                                            pins: {step: 9, direction: 10}
  end

  def test_initialize
    assert_equal Denko::DigitalIO::Output, part.step.class
    assert_equal Denko::DigitalIO::Output, part.direction.class
  end

  def test_step_cw
    dir_mock = Minitest::Mock.new
    dir_mock.expect :low?, false
    dir_mock.expect :low, nil
    step_mock = Minitest::Mock.new
    step_mock.expect :high, nil
    step_mock.expect :low, nil

    part.stub(:direction, dir_mock) do
      part.stub(:step, step_mock) do
        part.step_cw
      end
    end
    dir_mock.verify
    step_mock.verify
  end

  def test_step_ccw
    dir_mock = Minitest::Mock.new
    dir_mock.expect :high?, false
    dir_mock.expect :high, nil
    step_mock = Minitest::Mock.new
    step_mock.expect :high, nil
    step_mock.expect :low, nil

    part.stub(:direction, dir_mock) do
      part.stub(:step, step_mock) do
        part.step_ccw
      end
    end
    dir_mock.verify
    step_mock.verify
  end
end
