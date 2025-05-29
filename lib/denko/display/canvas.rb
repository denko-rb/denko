module Denko
  module Display
    class Canvas
      attr_reader :columns, :rows, :framebuffer, :framebuffers, :colors

      def initialize(columns, rows, colors: 1)
        @columns  = columns
        @rows     = rows
        @rows     = ((rows / 8.0).ceil * 8) if (rows % 8 != 0)
        # Use a byte array for the framebuffer. Each byte is 8 pixels arranged vertically.
        # Each slice @columns long represents an area @columns wide * 8 pixels tall.
        @bytes = @columns * (@rows / 8)

        # Framebuffer setup. 1-bit framebuffer for each color.
        # Works for mono LCDs and OLEDs, or mono/multi-color e-paper.
        @colors = colors
        @framebuffers = []
        @colors.times { @framebuffers << Array.new(@bytes) { 0x00 } }
        # Only first framebuffer is used for mono displays.
        @framebuffer = @framebuffers.first

        # Default drawing state
        self.font       = Denko::Display::Font::BMP_6X8
        @font_scale     = 1
        @current_color  = 1

        # Transformation state
        @swap_xy     = false
        @invert_x    = false
        @invert_y    = false
        @rotation    = 0
        calculate_bounds
      end

      def clear
        @framebuffers.each { |fb| fb.fill 0x00 }
      end

      def fill
        # Clear all buffers, then fill the first one, which is the only
        # one for mono displays, black for multi-color e-paper.
        clear
        @framebuffers.first.fill 0xFF
      end

      #
      # PIXEL OPERATIONS
      #
      def _get_pixel(x, y)
        byte = ((y / 8) * @columns) + x
        bit  = y % 8
        # Array with state per color.
        @framebuffers.map { |fb| (fb[byte] >> bit) & 0b00000001 }
      end

      def get_pixel(x:, y:)
        _get_pixel(x, y)
      end

      def _set_pixel(x, y, color=current_color)
        xt = (@invert_x) ? @x_max - x : x
        yt = (@invert_y) ? @y_max - y : y
        if (@swap_xy)
          tt = xt
          xt = yt
          yt = tt
        end

        # Bounds check
        return nil if (xt < 0 || yt < 0 || xt > @columns-1 || yt > @rows -1)
        return nil if (color < 0) || (color > colors)

        byte = ((yt / 8) * @columns) + xt
        bit  = yt % 8

        # Set pixel bit in that color's buffer. Clear in others.
        # When color == 0, clears in all buffers and sets in none.
        for i in 1..colors
          if (color == i)
            @framebuffers[i-1][byte] |= (0b1 << bit)
          else
            @framebuffers[i-1][byte] &= ~(0b1 << bit)
          end
        end
      end

      def set_pixel(x:, y:, color:current_color)
        _set_pixel(x, y, color)
      end

      def clear_pixel(x:, y:)
        _set_pixel(x, y, 0)
      end

      #
      # LINE
      #
      def _line(x1, y1, x2, y2, color=current_color)
        # Deltas in each axis.
        dy = y2 - y1
        dx = x2 - x1

        # Optimize vertical lines, and avoid division by 0.
        if (dx == 0)
          # Ensure y1 < y2.
          y1, y2 = y2, y1 if (y2 < y1)
          (y1..y2).each { |y| _set_pixel(x1, y, color) }
          return
        end

        # Optimize horizontal lines.
        if (dy == 0)
          # Ensure x1 < x2.
          x1, x2 = x2, x1 if (x2 < x1)
          (x1..x2).each { |x| _set_pixel(x, y1, color) }
          return
        end

        # Based on Bresenham's line algorithm
        # Slope calculations
        step_axis   = (dx.abs > dy.abs) ? :x : :y
        step_count  = (step_axis == :x)  ? dx.abs : dy.abs
        x_step      = (dx > 0) ? 1 : -1
        y_step      = (dy > 0) ? 1 : -1

        # Error calculations
        error_step      = (step_axis == :x) ? dy.abs : dx.abs
        error_threshold = (step_axis == :x) ? dx.abs : dy.abs

        x = x1
        y = y1
        error = 0
        (0..step_count).each do |i|
          _set_pixel(x, y, color)

          if (step_axis == :x)
            x += x_step
            error += error_step
            if (error >= error_threshold)
              y += y_step
              error -= error_threshold
            end
          else
            y += y_step
            error += error_step
            if (error >= error_threshold)
              x += x_step
              error -= error_threshold
            end
          end
        end
      end

      def line(x1:, y1:, x2:, y2:, color:current_color)
        _line(x1, y1, x2, y2, color)
      end

      #
      # RECTANGLE & SQUARE
      #
      def _rectangle(x1, y1, x2, y2, filled=false, color=current_color)
        if filled
          y1, y2 = y2, y1 if (y2 < y1)
          (y1..y2).each { |y| _line(x1, y, x2, y, color) }
        else
          _line(x1, y1, x2, y1, color)
          _line(x2, y1, x2, y2, color)
          _line(x2, y2, x1, y2, color)
          _line(x1, y2, x1, y1, color)
        end
      end

      def rectangle(x1:nil, y1:nil, x2:nil, y2:nil, x:nil, y:nil, w:nil, h:nil, filled:false, color:current_color)
        x1 ||= x
        y1 ||= y
        x2 ||= x1 + w - 1
        y2 ||= y1 + h - 1
        _rectangle(x1, y1, x2, y2, filled, color)
      end

      def square(x:, y:, size:, filled:false, color:current_color)
        rectangle(x: x, y: y, w: size, h: size, filled: filled, color: color)
      end

      #
      # PATH, POLYGON & TRIANGLE
      #
      def _path(points=[], color=current_color)
        start = points[0]
        (1..points.length-1).each do |i|
          finish = points[i]
          _line(start[0], start[1], finish[0], finish[1], color)
          start = finish
        end
      end

      def path(points=[], color:current_color)
        _path(points, color)
      end

      def _polygon(points=[], filled=false, color=current_color)
        if filled
          # Get all the X and Y coordinates from the points as floats.
          coords_x = points.map { |point| point.first.to_f }
          coords_y = points.map { |point| point.last.to_f  }

          # Get Y bounds of the polygon to limit rows.
          y_min = coords_y.min.to_i
          y_max = coords_y.max.to_i

          # Cast horizontal ray on each row, storing nodes where it intersects polygon edges.
          (y_min..y_max).each do |y|
            nodes = []
            i = 0
            j = points.count - 1

            while (i < points.count) do
              if (coords_y[i] < y && coords_y[j] >= y || coords_y[j] < y && coords_y[i] >= y)
                nodes << (coords_x[i] + (y - coords_y[i]) / (coords_y[j] - coords_y[i]) *(coords_x[j] - coords_x[i])).round
              end
              j  = i
              i += 1
            end
            nodes = nodes.sort

            # Take pairs of nodes and fill between them. This automatically ignores the spaces
            # between even then odd nodes, which are outside the polygon.
            nodes.each_slice(2) do |pair|
              next if pair.length < 2
              _line(pair.first, y,  pair.last, y, color)
            end
          end
        end

        # Stroke regardless, since floating point math misses thin areas of fill.
        _path(points, color)
        # Close open path by adding a line between the first and last points.
        _line(points[-1][0], points[-1][1], points[0][0], points[0][1], color)
      end

      def polygon(points=[], filled:false, color:current_color)
        _polygon(points, filled, color)
      end

      def _triangle(x1, y1, x2, y2, x3, y3, filled=false, color=current_color)
        if filled
          _polygon([[x1,y1], [x2,y2], [x3,y3]], filled, color)
        else
          _line(x1, y1, x2, y2, color)
          _line(x2, y2, x3, y3, color)
          _line(x3, y3, x1, y1, color)
        end
      end

      def triangle(x1:, y1:, x2:, y2:, x3:, y3:, filled:false, color:current_color)
        _triangle(x1, y1, x2, y2, x3, y3, filled, color)
      end


      def _ellipse(x_center, y_center, a, b, filled=false, color=current_color)
        # Midpoint ellipse / circle based on Bresenham's circle algorithm.
        # Start position
        x = -a
        y = 0

        # Precompute x and y increments for each step.
        x_increment = 2 * b * b
        y_increment = 2 * a * a

        # Start errors
        dx = (1 + (2 * x)) * b * b
        dy = x * x
        e1 = dx + dy
        e2 = dx

        # Since starting at max negative X, continue until x is 0.
        while (x <= 0)
          if filled
            # Fill left and right quadrants in single line, alternating +ve and -ve y.
            _line(x_center - x, y_center + y, x_center + x, y_center + y, color)
            _line(x_center - x, y_center - y, x_center + x, y_center - y, color)
          else
            # Stroke quadrants in order as if y-axis is reversed and going counter-clockwise from +ve X.
            _set_pixel(x_center - x, y_center - y, color)
            _set_pixel(x_center + x, y_center - y, color)
            _set_pixel(x_center + x, y_center + y, color)
            _set_pixel(x_center - x, y_center + y, color)
          end

          e2 = 2 * e1
          if (e2 >= dx)
            x  += 1
            dx += x_increment
            e1 += dx
          end
          if (e2 <= dy)
            y  += 1
            dy += y_increment
            e1 += dy
          end
        end

        # Continue if y hasn't reached the vertical size.
        while (y < b)
          y += 1
          _set_pixel(x_center, y_center + y, color)
          _set_pixel(x_center, y_center - y, color)
        end
      end

      def ellipse(x:, y:, a:, b:, filled:false, color:current_color)
        _ellipse(x, y, a, b, filled, color)
      end

      def circle(x:, y:, r:, filled:false, color:current_color)
        _ellipse(x, y, r, r, filled, color)
      end

      #
      # BITMAP TEXT
      #
      def text(str, color:current_color)
        str.to_s.split("").each { |char| draw_char(char, color: color) }
      end

      def draw_char(char, color:current_color)
        # 0th character in font is SPACE. Offset ASCII code and show ? if character doesn't exist in font.
        index = char.ord - 32
        index = 31 if (index < 0 || index > @font_last_character)
        char_map = @font_characters[index]

        # Offset by scaled height, since bottom left of char starts at text cursor.
        x = text_cursor[0]
        y = text_cursor[1] + 1 - (@font_height * @font_scale)

        # Draw it
        _draw_char(char_map, x, y, @font_width, @font_scale, color)

        # Increment the text cursor, scaling width.
        self.text_cursor[0] += @font_width * @font_scale
      end

      def _draw_char(byte_array, x, y, width, scale, color)
        byte_array.each_slice(width) do |slice|
          slice.each_with_index do |byte, col_offset|
            8.times do |bit|
              next if (((byte >> bit) & 0b1) == 0)

              scale.times do |x_offset|
                scale.times do |y_offset|
                  _set_pixel(x + (col_offset * scale) + x_offset, y + (bit * scale) + y_offset, color)
                end
              end
            end
          end
          y = y + (8 * scale)
        end
      end

      #
      # DRAWING STATE
      #
      def current_color=(color)
        raise Argument error, "color must be within (0..#{colors})" if (color < 0) || (color > colors)
        @current_color = color
      end

      attr_reader :current_color

      DEFAULT_TEXT_CURSOR = [0, 7]

      def text_cursor
        @text_cursor ||= DEFAULT_TEXT_CURSOR
      end

      def text_cursor=(array=DEFAULT_TEXT_CURSOR)
        @text_cursor = array
      end

      def font=(font)
        if font.class == Symbol
          @font = Display::Font.const_get(font.to_s.upcase)
        else
          @font = font
        end

        @font_height = @font[:height]
        @font_width = @font[:width]
        @font_characters = @font[:characters]
        @font_last_character = @font_characters.length - 1
      end

      def font_scale=(scale)
        raise ArgumentError, "#font_scale must be a positive integer" unless (scale.class == Integer) && scale > 0
        @font_scale = scale
      end

      attr_reader :font, :font_scale

      #
      # TRANSFORMATION
      #
      def rotate(degrees)
        raise ArgumentError, "Canvas can only be rotated in multiples of 90 degrees" unless (degrees % 90 == 0)
        old_rotation = @rotation
        @rotation = (old_rotation + degrees) % 360
        change = (@rotation - old_rotation) % 360

        (change / 90).times do
          @swap_xy = !@swap_xy
          if (!@invert_x && !@invert_y)
            @invert_x = true
            @invert_y = false
          elsif (@invert_x && !@invert_y)
            @invert_x = true
            @invert_y = true
          elsif (@invert_x && @invert_y)
            @invert_x = false
            @invert_y = true
          elsif (!@invert_x && @invert_y)
            @invert_x = false
            @invert_y = false
          end
        end
        calculate_bounds
      end

      def reflect(axis)
        raise ArgumentError "Canvas can only be reflected in :x or :y axis" unless [:x, :y].include? (axis)
        (axis == :x) ? @invert_x = !@invert_x : @invert_y = !@invert_y
        calculate_bounds
      end

      def calculate_bounds
        if @swap_xy
          @x_max = @rows - 1
          @y_max = @columns - 1
        else
          @x_max = @columns - 1
          @y_max = @rows - 1
        end
      end

      attr_reader :x_max, :y_max
    end
  end
end
