module Denko
  module Display
    class Canvas
      include Denko::Fonts

      attr_reader :columns, :rows, :framebuffer, :font

      def initialize(columns, rows)
        @columns = columns
        @rows = rows
        @rows = ((rows / 8.0).ceil * 8).to_i if (rows % 8 != 0)

        self.font    = Denko::Fonts::LED_6x8
        @font_scale  = 1

        @swap_xy     = false
        @invert_x    = false
        @invert_y    = false
        @rotation    = 0
        compute_limits

        # Use a byte array for the framebuffer. Each byte is 8 pixels arranged vertically.
        # Each slice @columns long represents an area @columns wide * 8 pixels tall.
        @bytes       = @columns * (@rows / 8)
        @framebuffer = Array.new(@bytes) { 0x00 }
      end

      def fill
        @framebuffer.fill(0xFF)
      end

      def clear
        @framebuffer.fill(0x00)
      end

      def get_pixel(x, y)
        byte = ((y / 8) * @columns) + x
        bit  = y % 8
        (@framebuffer[byte] >> bit) & 0b00000001
      end

      def pixel(x, y, color=0)
        xt = (@invert_x) ? @x_max - x : x
        yt = (@invert_y) ? @y_max - y : y
        if (@swap_xy)
          tt = xt
          xt = yt
          yt = tt
        end

        return nil if (xt < 0 || yt < 0 || xt > @columns-1 || yt > @rows -1)

        byte = ((yt / 8) * @columns) + xt
        bit  = yt % 8

        if (color == 0)
          @framebuffer[byte] &= ~(0b1 << bit)
        else
          @framebuffer[byte] |= (0b1 << bit)
        end
      end

      def set_pixel(x, y)
        pixel(x, y, 1)
      end

      def clear_pixel(x, y)
        pixel(x, y, 0)
      end

      # Draw a line based on Bresenham's line algorithm.
      def line(x1, y1, x2, y2, color=1)
        # Deltas in each axis.
        dy = y2 - y1
        dx = x2 - x1

        # Optimize vertical lines, and avoid division by 0.
        if (dx == 0)
          # Ensure y1 < y2.
          y1, y2 = y2, y1 if (y2 < y1)
          (y1..y2).each do |y|
            pixel(x1, y, color)
          end
          return
        end

        # Optimize horizontal lines.
        if (dy == 0)
          # Ensure x1 < x2.
          x1, x2 = x2, x1 if (x2 < x1)
          (x1..x2).each do |x|
            pixel(x, y1, color)
          end
          return
        end

        # Bresenham's algorithm for sloped lines.
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
          pixel(x, y, color)

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

      # Rectangles and squares as a combination of lines.
      def rectangle(x, y, width, height, color=1)
        line(x,       y,        x+width, y,        color)
        line(x+width, y,        x+width, y+height, color)
        line(x+width, y+height, x,       y+height, color)
        line(x,       y+height, x,       y,        color)
      end

      # Draw a vertical line for every x value to get a filled rectangle.
      def filled_rectangle(x, y_start, width, height, color=1)
        y_end = y_start + height
        y_start, y_end = y_end, y_start if (y_end < y_start)
        (y_start..y_end).each do |y|
          line(x, y, x+width, y, color)
        end
      end

      # Open ended path
      def path(points=[], color=1)
        return unless points
        start = points[0]
        (1..points.length-1).each do |i|
          finish = points[i]
          line(start[0], start[1], finish[0], finish[1], color)
          start = finish
        end
      end

      # Close paths by repeating the start value at the end.
      def polygon(points=[], color=1)
        points << points[0]
        path(points, color)
      end

      # Filled polygon using horizontal ray casting + stroked polygon.
      def filled_polygon(points=[], color=1)
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
            line(pair.first, y,  pair.last, y, color)
          end
        end

        # Stroke the polygon anyway. Floating point math misses thin areas.
        polygon(points, color)
      end

      # Triangle with 3 points as 6 flat args.
      def triangle(x1, y1, x2, y2, x3, y3, color=1)
        polygon([[x1,y1], [x2,y2], [x3,y3]], color)
      end

      # Filled triangle with 3 points as 6 flat args.
      def filled_triangle(x1, y1, x2, y2, x3, y3, color=1)
        filled_polygon([[x1,y1], [x2,y2], [x3,y3]], color)
      end

      # Midpoint ellipse / circle based on Bresenham's circle algorithm.
      def ellipse(x_center, y_center, a, b, color=1, filled=false)
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
            fill_quadrants(x_center, y_center, x, y, color)
          else
            stroke_quadrants(x_center, y_center, x, y, color)
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
          pixel(x_center, y_center + y, color)
          pixel(x_center, y_center - y, color)
        end
      end

      def stroke_quadrants(x_center, y_center, x, y, color)
        # Quadrants in order as if y-axis is reversed and going counter-clockwise from +ve X.
        pixel(x_center - x, y_center - y, color)
        pixel(x_center + x, y_center - y, color)
        pixel(x_center + x, y_center + y, color)
        pixel(x_center - x, y_center + y, color)
      end

      def fill_quadrants(x_center, y_center, x, y, color)
        line(x_center - x, y_center + y, x_center + x, y_center + y, color)
        line(x_center - x, y_center - y, x_center + x, y_center - y, color)
      end

      def circle(x_center, y_center, radius, color=1, filled=false)
        ellipse(x_center, y_center, radius, radius, color, filled)
      end

      def filled_circle(x_center, y_center, radius, color=1)
        ellipse(x_center, y_center, radius, radius, color, true)
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
        change = @rotation - old_rotation

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
        @font = font
        @font_height = font[:height]
        @font_width = font[:width]
        @font_characters = font[:characters]
        @font_last_character = @font_characters.length - 1
      end

      def text(str)
        str.to_s.split("").each { |char| show_char(char) }
      end

      def show_char(char)
        # 0th character in font is SPACE. Offset ASCII code and show ? if character doesn't exist in font.
        index = char.ord - 32
        index = 31 if (index < 0 || index > @font_last_character)
        char_map = @font_characters[index]
        raw_char(char_map)
      end

      def raw_char(byte_array)
        x = text_cursor[0]
        # Offset by scaled height, since bottom left of char starts at text cursor.
        y = text_cursor[1] + 1 - (@font_height * @font_scale)

        if @font_height > 8
          slices = byte_array.each_slice(@font_width)
        else
          slices = [byte_array]
        end

        slices.each do |slice|
          # Each byte (column) in the char
          slice.each_with_index do |byte, col_offset|
            # Each bit in the byte
            8.times do |bit|
              pixel_value = (byte & (1 << bit))
              @font_scale.times do |x_offset|
                @font_scale.times do |y_offset|
                  pixel(x + (col_offset * @font_scale) + x_offset, y + (bit * @font_scale) + y_offset, pixel_value)
                end
              end
            end
          end
          y = y + (8 * @font_scale)
        end

        # Increment the text cursor, scaling width.
        self.text_cursor[0] += @font_width * @font_scale
      end
    end
  end
end
