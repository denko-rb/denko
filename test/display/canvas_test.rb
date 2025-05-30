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

  def test_clear
    setup_test_pixels
    empty  = Array.new(FB_LENGTH) { 0x00 }

    subject.clear
    assert_equal empty, subject.framebuffers[0]
    assert_equal empty,  subject.framebuffers[1]
  end

  def test_fill
    empty  = Array.new(FB_LENGTH) { 0x00 }
    filled = Array.new(FB_LENGTH) { 0xFF }

    subject.fill
    assert_equal filled, subject.framebuffers[0]
    assert_equal empty,  subject.framebuffers[1]
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

  def test_line_single_pixel
    subject.line x1: 5, y1: 5, x2: 5, y2: 5

    fb0 = Array.new(FB_LENGTH) { 0 }
    fb0[5] = 0b00100000

    assert_equal fb0, subject.framebuffers[0]
  end

  LINE_HORIZONTAL_FB = [0, 0, 32, 32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  def test_line_horizontal
    subject.line x1: 2, y1: 5, x2: 6, y2: 5
    assert_equal LINE_HORIZONTAL_FB, subject.framebuffers[0]
  end

  LINE_VERTICAL_FB = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 124, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  def test_line_vertical
    subject.line x1: 10, y1: 2, x2: 10, y2: 6
    assert_equal LINE_VERTICAL_FB, subject.framebuffers[0]
  end

  # 45 degree diagonal lines should produce the same result regardless of which is the start point (x1,y1).
  LINE_45_FB = [0, 0, 0, 0, 0, 32, 64, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  def test_line_45
    subject.line x1: 5, y1: 5, x2: 10, y2: 10
    assert_equal LINE_45_FB, subject.framebuffers[0]
  end

  def test_line_45_swapped
    subject.line x1: 10, y1: 10, x2: 5, y2: 5
    assert_equal LINE_45_FB, subject.framebuffers[0]
  end

  # Non 45 degree diagonals are approximated slightly differently, depending on which point is x1,y1.
  # This behavior might be useful.
  # +ve gradients tend to "pull" down and to the left.
  # -ve gradients tend to "pull" up and to the right.
  LINE_DIAG_POS_FB = [0, 0, 0, 0, 0, 96, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  LINE_DIAG_NEG_FB = [0, 0, 0, 0, 0, 32, 64, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  def test_line_diagonal
    # Note: run and rise not equal.
    subject.line x1: 5, y1: 5, x2: 8, y2: 10
    assert_equal LINE_DIAG_POS_FB, subject.framebuffers[0]
  end

  def test_line_diagonal_swapped
    # Note: run and rise not equal.
    subject.line x1: 8, y1: 10, x2: 5, y2: 5
    assert_equal LINE_DIAG_NEG_FB, subject.framebuffers[0]
  end

  def test_line_knockout
    inverted_fb = LINE_DIAG_POS_FB.map { |byte| ~byte & 0xFF }

    subject.fill
    subject.line x1: 5, y1: 5, x2: 8, y2: 10, color: 0
    assert_equal inverted_fb, subject.framebuffers[0]
  end

  RECTANGLE_FB = [0, 0, 0, 0, 0, 224, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 224, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 127, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 127, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  def test_rectangle1
    subject.rectangle x1: 5, y1: 5, x2: 19, y2: 14
    assert_equal RECTANGLE_FB, subject.framebuffers[0]
  end

  def test_rectangle2
    # w is x2-x1+1 (15) from previous, since first pixel counts
    # h ix y2-y1+1 (10) from previous, since first pixel counts
    subject.rectangle x1: 5, y1: 5, w: 15, h: 10
    assert_equal RECTANGLE_FB, subject.framebuffers[0]
  end

  SQUARES_FB = [0, 0, 0, 0, 0, 224, 224, 96, 96, 96, 96, 96, 96, 224, 224, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 127, 127, 96, 96, 96, 96, 96, 96, 127, 127, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  def test_layered_squares
    subject.square x: 5, y: 5, size: 10, filled: true, color: 1
    subject.square x: 7, y: 7, size: 6,  filled: true, color: 0
    assert_equal SQUARES_FB, subject.framebuffers[0]
  end

  PATH_FB = [3, 4, 24, 32, 192, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 64, 224, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 4, 4, 8, 16, 32, 32, 64, 128, 128, 64, 48, 8, 4, 3, 0, 0, 1, 14, 112, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 28, 224, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 56, 64]

  def path_points
     [ [0,0], [7,10], [15, 16], [23,5], [31, 30] ]
  end

  def test_path
    subject.path path_points, color: 2
    assert_equal PATH_FB, subject.framebuffers[1]
  end

  def test_path_knockout
    inverted_fb = PATH_FB.map { |byte| ~byte & 0xFF }

    subject.fill
    subject.path path_points, color: 0
    assert_equal inverted_fb, subject.framebuffers[0]
  end

  TRIANGLE_FB = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 96, 24, 6, 12, 48, 192, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 96, 24, 6, 193, 240, 124, 31, 62, 248, 224, 131, 12, 48, 192, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 96, 24, 6, 129, 224, 120, 31, 7, 1, 0, 0, 0, 0, 3, 15, 62, 240, 192, 3, 12, 48, 192, 0, 0, 0, 0, 0, 128, 224, 152, 134, 129, 128, 152, 158, 159, 159, 158, 158, 158, 158, 158, 158, 158, 158, 158, 158, 158, 159, 159, 159, 156, 128, 128, 131, 140, 176, 192]

  def triangle_points
    [
      [ [1,31],  [31,31], [16,1]  ],
      [ [7,28],  [25,28], [16,8]  ],
      [ [11,24], [21,24], [16,13] ],
    ]
  end

  def test_polygon
    subject.polygon triangle_points[0]
    subject.polygon triangle_points[1], filled: true
    subject.polygon triangle_points[2], filled: true, color: 0
    assert_equal TRIANGLE_FB, subject.framebuffers[0]
  end

  def test_triangle
    t = triangle_points
    subject.triangle x1: t[0][0][0], y1: t[0][0][1], x2: t[0][1][0], y2: t[0][1][1], x3: t[0][2][0], y3: t[0][2][1]
    subject.triangle x1: t[1][0][0], y1: t[1][0][1], x2: t[1][1][0], y2: t[1][1][1], x3: t[1][2][0], y3: t[1][2][1], filled: true
    subject.triangle x1: t[2][0][0], y1: t[2][0][1], x2: t[2][1][0], y2: t[2][1][1], x3: t[2][2][0], y3: t[2][2][1], filled: true, color: 0
    assert_equal TRIANGLE_FB, subject.framebuffers[0]
  end
end
