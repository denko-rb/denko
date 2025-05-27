module Denko
  module Display
    class Canvas
      attr_reader :columns, :rows, :framebuffer, :framebuffers, :colors, :font, :x_max, :y_max

      def initialize(columns, rows, colors: 1)
        @columns = columns
        @rows = rows
        @rows = ((rows / 8.0).ceil * 8) if (rows % 8 != 0)

        self.font    = Denko::Display::Font::BMP_6X8
        @font_scale  = 1

        @swap_xy     = false
        @invert_x    = false
        @invert_y    = false
        @rotation    = 0
        compute_limits

        # Use a byte array for the framebuffer. Each byte is 8 pixels arranged vertically.
        # Each slice @columns long represents an area @columns wide * 8 pixels tall.
        @bytes       = @columns * (@rows / 8)

        # Create a separate 1-bit framebuffer for each color.
        # For mono LCDs, OLEDs e-paper, or e-paper with 2 or 3 colors + white.
        @colors = colors
        @framebuffers = []
        @colors.times { @framebuffers << Array.new(@bytes) { 0x00 } }
        # Default framebuffer when 1 color.
        @framebuffer = @framebuffers.first
      end

      def fill
        # Clear all other buffers, and fill the first one.
        # This should be black on e-paper, and default color on other displays.
        clear
        @framebuffers.first.fill 0xFF
      end

      def clear
        @framebuffers.each { |fb| fb.fill 0x00 }
      end

      def get_pixel(x, y)
        byte = ((y / 8) * @columns) + x
        bit  = y % 8
        # Array with state per color.
        @framebuffers.map { |fb| (fb[byte] >> bit) & 0b00000001 }
      end

      def pixel(x, y, color: current_color)
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
            @framebuffers[color-1][byte] |= (0b1 << bit)
          else
            @framebuffers[color-1][byte] &= ~(0b1 << bit)
          end
        end
      end

      def set_pixel(x, y, color: current_color)
        pixel(x, y, color: color)
      end

      def clear_pixel(x, y)
        pixel(x, y, color: 0)
      end

      # Based on Bresenham's line algorithm.
      def line(x1, y1, x2, y2, color: current_color)
        # Deltas in each axis.
        dy = y2 - y1
        dx = x2 - x1

        # Optimize vertical lines, and avoid division by 0.
        if (dx == 0)
          # Ensure y1 < y2.
          y1, y2 = y2, y1 if (y2 < y1)
          (y1..y2).each do |y|
            pixel(x1, y, color: color)
          end
          return
        end

        # Optimize horizontal lines.
        if (dy == 0)
          # Ensure x1 < x2.
          x1, x2 = x2, x1 if (x2 < x1)
          (x1..x2).each do |x|
            pixel(x, y1, color: color)
          end
          return
        end

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
          pixel(x, y, color: color)

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

      def rectangle(x, y, width, height, color: current_color, filled: false)
        if filled
          y_start = y
          y_end = y_start + height
          y_start, y_end = y_end, y_start if (y_end < y_start)
          (y_start..y_end).each do |y|
            line(x, y, x+width, y, color: color)
          end
        else
          line(x,       y,        x+width, y,        color: color)
          line(x+width, y,        x+width, y+height, color: color)
          line(x+width, y+height, x,       y+height, color: color)
          line(x,       y+height, x,       y,        color: color)
        end
      end

      def square(x, y, size, color: current_color, filled: false)
        rectangle(x, y, size, size, color: color, filled: filled)
      end

      # Open ended path
      def path(points=[], color: current_color)
        return unless points
        start = points[0]
        (1..points.length-1).each do |i|
          finish = points[i]
          line(start[0], start[1], finish[0], finish[1], color: color)
          start = finish
        end
      end

      # Close paths by repeating the start value at the end.
      def polygon(points=[], color: current_color)
        points << points[0]
        path(points, color: color)
      end

      # Filled polygon using horizontal ray casting + stroked polygon.
      def filled_polygon(points=[], color: current_color)
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
            line(pair.first, y,  pair.last, y, color: color)
          end
        end

        # Stroke the polygon anyway. Floating point math misses thin areas.
        polygon(points, color: color)
      end

      # Triangle with 3 points as 6 flat args.
      def triangle(x1, y1, x2, y2, x3, y3, color: current_color)
        polygon([[x1,y1], [x2,y2], [x3,y3]], color: color)
      end

      # Filled triangle with 3 points as 6 flat args.
      def filled_triangle(x1, y1, x2, y2, x3, y3, color: current_color)
        filled_polygon([[x1,y1], [x2,y2], [x3,y3]], color: color)
      end

      # Midpoint ellipse / circle based on Bresenham's circle algorithm.
      def ellipse(x_center, y_center, a, b, color: current_color, filled: false)
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
            line(x_center - x, y_center + y, x_center + x, y_center + y, color: color)
            line(x_center - x, y_center - y, x_center + x, y_center - y, color: color)
          else
            # Stroke quadrants in order as if y-axis is reversed and going counter-clockwise from +ve X.
            pixel(x_center - x, y_center - y, color: color)
            pixel(x_center + x, y_center - y, color: color)
            pixel(x_center + x, y_center + y, color: color)
            pixel(x_center - x, y_center + y, color: color)
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
          pixel(x_center, y_center + y, color: color)
          pixel(x_center, y_center - y, color: color)
        end
      end

      def circle(x_center, y_center, radius, color: current_color, filled: false)
        ellipse(x_center, y_center, radius, radius, color: color, filled: filled)
      end

      def filled_circle(x_center, y_center, radius, color: current_color)
        ellipse(x_center, y_center, radius, radius, color: color, filled: true)
      end

      def text_cursor=(array=[])
        @text_cursor = array
      end

      def text_cursor
        @text_cursor ||= [0, 7]
      end

      def rotate(degrees)
        raise ArgumentError, "canvas can only be rotated by multiples of 90 degrees" unless (degrees % 90 == 0)
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
        compute_limits
      end

      def reflect(axis)
        raise ArgumentError "invalid axis for canvas reflection. Only :x or :y accepted" unless [:x, :y].include? (axis)
        (axis == :x) ? @invert_x = !@invert_x : @invert_y = !@invert_y
        compute_limits
      end

      def compute_limits
        if @swap_xy
          @x_max = @rows - 1
          @y_max = @columns - 1
        else
          @x_max = @columns - 1
          @y_max = @rows - 1
        end
      end

      def font_scale=(scale)
        raise ArgumentError, "text scale must be a positive integer" unless (scale.class == Integer) && scale > 0
        @font_scale = scale
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

      def current_color
        @current_color ||= 1
      end

      def current_color=(color)
        raise Argument error, "invalid color" if (color < 0) || (color > colors)
        @current_color = color
      end

      def text(str, color: current_color)
        str.to_s.split("").each { |char| show_char(char, color: color) }
      end

      def show_char(char, color: current_color)
        # 0th character in font is SPACE. Offset ASCII code and show ? if character doesn't exist in font.
        index = char.ord - 32
        index = 31 if (index < 0 || index > @font_last_character)
        char_map = @font_characters[index]

        # Offset by scaled height, since bottom left of char starts at text cursor.
        x = text_cursor[0]
        y = text_cursor[1] + 1 - (@font_height * @font_scale)

        # Draw it
        raw_char(char_map, x, y, @font_width, @font_scale, color: color)

        # Increment the text cursor, scaling width.
        self.text_cursor[0] += @font_width * @font_scale
      end

      def raw_char(byte_array, x, y, width, scale, color: current_color)
        byte_array.each_slice(width) do |slice|
          slice.each_with_index do |byte, col_offset|
            8.times do |bit|
              color_val = (((byte >> bit) & 0b1) > 0) ? color : 0
              scale.times do |x_offset|
                scale.times do |y_offset|
                  pixel(x + (col_offset * scale) + x_offset, y + (bit * scale) + y_offset, color: color_val)
                end
              end
            end
          end
          y = y + (8 * scale)
        end
      end
    end
  end
end
