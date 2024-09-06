require_relative 'ssd1306'

module Denko
  module Display
    class SH1106 < SSD1306
      #
      # Unlike the SSD1306, SH1106 only supports page addressing mode.
      # Can't send all data as sequential pages and let page index auto-increment,
      # like with horizontal addressing on the SSD1306.
      #
      ADDRESSING_MODE_DEFAULT = 0x02

      def draw(x_min=0, x_max=(@columns-1), y_min=0, y_max=(@rows-1))
        # Convert y-coords to page coords.
        p_min = y_min / 8
        p_max = y_max / 8

        # Offset x_min by 2, since SH1106 has RAM for 132 columns, but we only use 128, then convert to nibbles.
        x = x_min + 2
        x_lower = (x & 0b00001111)
        x_upper = (x & 0b11110000) >> 4

        (p_min..p_max).each do |page|
          # Set the page and column to start writing at.
          command [PAGE_START | page, COLUMN_START_LOWER | x_lower, COLUMN_START_UPPER | x_upper]

          # Get needed bytes for this page only.
          src_start = (@columns * page) + x_min
          src_end   = (@columns * page) + x_max
          buffer    = canvas.framebuffer[src_start..src_end]

          # Send all bytes at once if within limit, or split into chunks.
          if buffer.length < (bus.board.i2c_limit - 1)
            data(buffer)
          else  
            buffer.each_slice(bus.board.i2c_limit - 1) { |slice| data(slice) }
          end
        end
      end
    end
  end
end
