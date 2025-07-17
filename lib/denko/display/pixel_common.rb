module Denko
  module Display
    module PixelCommon
      def columns
        return @columns if @columns
        @columns = self.class.const_get("COLUMNS") if self.class.const_defined?("COLUMNS")
        @columns = params[:width] if params[:width]
        @columns = params[:columns] if params[:columns]
        @columns
      end
      alias :cols :columns

      def rows
        return @rows if @rows
        @rows = self.class.const_get("ROWS") if self.class.const_defined?("ROWS")
        @rows = params[:height] if params[:height]
        @rows = params[:rows] if params[:rows]
        @rows
      end

      def x_min
        @x_min ||= 0
      end

      def x_max
        @x_max ||= columns - 1
      end

      def y_min
        @y_min ||= 0
      end

      def y_max
        @y_max ||= rows - 1
      end

      def p_min
        @p_min ||= 0
      end

      def p_max
        @p_max ||= (rows / 8.0).ceil - 1
      end

      def colors
        @colors ||= params[:colors] || 1
      end

      def canvas
        @canvas ||= Canvas.new(columns, rows, colors: colors)
      end

      def refresh
      end

      def get_partial_buffer(buffer, x_start, x_finish, p_start, p_finish)
        # If bounds == max bounds, just return the buffer.
        return buffer if (x_start == x_min) && (x_finish == x_max) && (p_start == p_min) && (p_finish == p_max)

        # Copy bytes for the given rectangle into a temp buffer.
        temp_buffer = []
        (p_start..p_finish).each do |page|
          src_start = (columns * page) + x_start
          src_end   = (columns * page) + x_finish
          length    = (src_end - src_start) + 1
          (0...length).each { |i| temp_buffer << buffer[src_start+i].ord }
        end
        temp_buffer
      end

      def draw(x_start=x_min, x_finish=x_max, y_start=y_min, y_finish=y_max)
        # Convert y-coords to page coords.
        p_start  = y_start  / 8
        p_finish = y_finish / 8

        colors.times do |i|
          draw_partial(canvas.framebuffers[i], x_start, x_finish, p_start, p_finish, i+1)
        end

        refresh
      end
    end
  end
end
