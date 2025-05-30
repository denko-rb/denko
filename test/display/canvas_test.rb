require_relative '../test_helper'

class CanvasTest < Minitest::Test
  WIDTH     = 32
  HEIGHT    = 32
  FB_LENGTH = (WIDTH * HEIGHT / 8)

  def subject
    @subject ||= Denko::Display::Canvas.new(WIDTH, HEIGHT, colors: 2)
  end

  def test_framebuffer_default_state
    assert_equal 2, subject.framebuffers.length
    assert_equal subject.framebuffer.object_id, subject.framebuffers.first.object_id
    assert_equal Array.new(FB_LENGTH) { 0x00 }, subject.framebuffers[0]
    assert_equal Array.new(FB_LENGTH) { 0x00 }, subject.framebuffers[1]
  end

  def test_transform_default_state
    refute subject.instance_variable_get(:@swap_xy)
    refute subject.instance_variable_get(:@invert_x)
    refute subject.instance_variable_get(:@invert_y)
    assert_equal 0, subject.instance_variable_get(:@rotation)
  end

  def test_drawing_default_state
    assert_equal 1, subject.current_color
    assert_equal 1, subject.font_scale
  end

  def setup_test_pixels
    subject.set_pixel x: 0,   y: 0,   color: 1
    subject.set_pixel x: 1,   y: 1,   color: 2
    subject.set_pixel x: 14,  y: 14,  color: 1
    subject.set_pixel x: 15,  y: 15,  color: 2
  end

  def test_set_pixel
    setup_test_pixels

    fb0 = Array.new(FB_LENGTH) { 0 }
    fb0[0]        = 0b00000001
    fb0[WIDTH+14] = 0b01000000
    assert_equal fb0, subject.framebuffers[0]

    fb1 = Array.new(FB_LENGTH) { 0 }
    fb1[1]        = 0b00000010
    fb1[WIDTH+15] = 0b10000000
    assert_equal fb1, subject.framebuffers[1]

    # Setting a pixel in FB 0 (color: 1) clears corresponding bit in FB 1 (color: 2).
    subject.set_pixel x: 1, y: 1, color: 1
    assert_equal 0b00000010, subject.framebuffers[0][1]
    assert_equal 0b00000000, subject.framebuffers[1][1]

    # Setting a pixel to color: 0 clears it in all FBs.
    subject.set_pixel x: 0,   y: 0,   color: 0
    assert_equal 0b00000000, subject.framebuffers[0][0]
    assert_equal 0b00000000, subject.framebuffers[1][0]

    subject.set_pixel x: 15,  y: 15,  color: 0
    assert_equal 0b00000000, subject.framebuffers[0][WIDTH+15]
    assert_equal 0b00000000, subject.framebuffers[1][WIDTH+15]
  end

  def test_get_pixel
    setup_test_pixels
    assert_equal 1, subject.get_pixel(x: 0,   y: 0)
    assert_equal 2, subject.get_pixel(x: 15,  y: 15)
    assert_equal 0, subject.get_pixel(x: 20,  y: 20)
  end
end
