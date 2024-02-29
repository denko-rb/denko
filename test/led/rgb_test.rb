require_relative '../test_helper'

class RGBLEDTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def options
    { board: board, pins: { red: 1, green: 2, blue: 3 } }
  end

  def part
    @part ||= Denko::LED::RGB.new(options)
  end

  def test_proxies
    assert_equal Denko::LED::Base, part.red.class
    assert_equal Denko::LED::Base, part.green.class
    assert_equal Denko::LED::Base, part.blue.class
  end

  def test_write
    red_mock = Minitest::Mock.new.expect :write, nil, [0]
    green_mock = Minitest::Mock.new.expect :write, nil, [128]
    blue_mock = Minitest::Mock.new.expect :write, nil, [0]

    part.stub(:red, red_mock) do
      part.stub(:green, green_mock) do
        part.stub(:blue, blue_mock) do
          part.write(0, 128, 0)
        end
      end
    end
    red_mock.verify
    green_mock.verify
    blue_mock.verify
  end

  def test_raw_rgb_values
    mock = Minitest::Mock.new.expect :call, nil, [128,0,0]
    part.stub(:write, mock) do
      part.write(128,0,0)
    end
    mock.verify
  end

  def test_color_names
    colors = Denko::LED::RGB::COLORS

    mock = Minitest::Mock.new
    colors.each_value do |color|
      mock.expect :call, nil, [*color]
      mock.expect :call, nil, [*color]
    end

    part.stub(:write, mock) do
      colors.each_key do |key|
        part.color = key
        part.color = key.to_s
      end
    end
    mock.verify
  end
end
