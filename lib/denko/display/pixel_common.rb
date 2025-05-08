module Denko
  module Display
    module PixelCommon
      def canvas
        @canvas ||= Canvas.new(columns, rows)
      end

      def draw(x_min=0, x_max=(columns-1), y_min=0, y_max=(rows-1))
        # Convert y-coords to page coords.
        p_min = y_min / 8
        p_max = y_max / 8

        # If drawing the whole frame (default), bypass temp buffer to save time.
        if (x_min == 0) && (x_max == columns-1) && (p_min == 0) && (p_max == rows/8)
          draw_partial(canvas.framebuffer, x_min, x_max, p_min, p_max)

        # Copy bytes for the given rectangle into a temp buffer.
        else
          temp_buffer = []
          (p_min..p_max).each do |page|
            src_start = (columns * page) + x_min
            src_end   = (columns * page) + x_max
            temp_buffer += canvas.framebuffer[src_start..src_end]
          end

          # And draw them.
          draw_partial(temp_buffer, x_min, x_max, p_min, p_max)
        end
      end
    end
  end
end
