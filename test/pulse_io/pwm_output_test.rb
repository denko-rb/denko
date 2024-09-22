require_relative '../test_helper'

class PWMOutTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Denko::PulseIO::PWMOutput.new(board: board, pin: 14)
  end

  def part2
    @part2 ||= Denko::PulseIO::PWMOutput.new(board: board, pin: 6, frequency: 1000, resolution: 12)
  end

  def test_initialize_stores_settings
    assert_equal 12,        part2.resolution
    assert_equal 1000,      part2.frequency
    assert_equal (2**12-1), part2.pwm_high
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
    args = [14, :output_pwm, {frequency: nil, resolution: nil}]
    mock = Minitest::Mock.new.expect :call, nil, args
    board.stub(:set_pin_mode, mock) do
      part.pwm_enable
    end
    mock.verify
    assert_equal :output_pwm, part.mode
    assert_equal true,        part.pwm_enabled
  end

  def test_pwm_enable_uses_stored_settings
    part2
    args = [6, :output_pwm, {frequency: 1000, resolution: 12}]
    mock = Minitest::Mock.new.expect :call, nil, args
    board.stub(:set_pin_mode, mock) do
      part2.pwm_enable
    end
    mock.verify
    assert_equal :output_pwm, part2.mode
    assert_equal true,        part2.pwm_enabled
  end

  def test_pwm_enable_uses_arg_settings
    part
    args = [14, :output_pwm, {frequency: 500, resolution: 14}]
    mock = Minitest::Mock.new.expect :call, nil, args
    board.stub(:set_pin_mode, mock) do
      part.pwm_enable(frequency: 500, resolution: 14)
    end
    mock.verify
    assert_equal :output_pwm, part.mode
    assert_equal true,        part.pwm_enabled
    assert_equal 14,          part.resolution
    assert_equal 500,         part.frequency
    assert_equal (2**14-1),   part.pwm_high
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
    assert_equal false, part.pwm_enabled
  end
end
