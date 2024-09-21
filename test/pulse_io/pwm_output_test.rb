require_relative '../test_helper'

class PWMOutTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::PulseIO::PWMOutput.new(board: board, pin: 14)
  end
  
  def test_pwm_write
    enable_mock = Minitest::Mock.new.expect :call, nil
    write_mock = Minitest::Mock.new
    write_mock.expect :call, nil, [14, 128]
  
    board.stub(:pwm_write, write_mock) do
      part.stub(:pwm_enable, enable_mock) do
        assert_equal :output, part.mode
        part.pwm_write(128)
        assert_equal 128, part.state
      end
    end
    
    part.pwm_write(64)
    assert_equal 64, part.state
    assert_equal :output_pwm, part.mode

    write_mock.verify
    enable_mock.verify
  end

  def test_write_uses_board_pwm_write_always
    mock = Minitest::Mock.new.expect :call, nil, [14, 128]
    board.stub(:pwm_write, mock) do
      part.write(128)
    end
    mock.verify
  end
  
  def test_pwm_enable
    part
    mock = Minitest::Mock.new.expect :call, nil, [14, :output_pwm]
    board.stub(:set_pin_mode, mock) do
      part.pwm_enable
    end
    mock.verify
    assert_equal :output_pwm, part.mode
  end
    
  def test_pwm_disable
    part.pwm_enable
    mock = Minitest::Mock.new
    mock.expect :call, nil, [14, :output]
    board.stub(:set_pin_mode, mock) do
      part.pwm_disable
    end
    mock.verify
    assert_equal :output, part.mode
  end
end
