require_relative '../test_helper'

class ServoMotorTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::Motor::Servo.new(board: board, pin:1, min: 0, max: 360)
  end

  def test_toggle_on_initialize
    mock = Minitest::Mock.new.expect(:call, nil, [1, :on], min: 500, max: 2500)
    board.stub(:servo_toggle, mock) do
      Denko::Motor::Servo.new(board: board, pin:1)
    end
    mock.verify
  end

  def test_attach
    part
    mock = Minitest::Mock.new.expect(:call, nil, [1, :on], min: 0, max: 360)
    board.stub(:servo_toggle, mock) { part.attach }
    mock.verify
  end

  def test_detach
    part
    mock = Minitest::Mock.new.expect(:call, nil, [1, :off])
    board.stub(:servo_toggle, mock) { part.detach }
    mock.verify
  end

  def test_position_modulo_180
    part.position = 190
    assert_equal 10, part.position
    part.position = 180
    assert_equal 180, part.position
    part.position = 0
    assert_equal 0, part.position
    part.position = -1
    assert_equal 179, part.position
  end

  def test_position_writes_mapped_microseconds_to_board
    part
    mock = Minitest::Mock.new.expect(:call, nil, [1, 20])
    board.stub(:servo_write, mock) do
      part.position = 10
    end
    mock.verify
  end

  def test_speed_writes_mapped_microseconds_to_board
    part
    mock = Minitest::Mock.new.expect(:call, nil, [1, 180])
    board.stub(:servo_write, mock) do
      part.speed = 0
    end
    mock.verify
  end
end
