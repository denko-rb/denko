module Denko
  module Display
    class SH1106
      include MonoOLED
      #
      # SH1106/SH1107 only support page addressing mode.
      # Can't send all data as sequential pages and let page index auto-increment,
      # like with horizontal addressing on the SSD1306.
      #
      ADDRESSING_MODE_DEFAULT = 0x02
      RAM_X_OFFSET = 2
      #
      # SH1106 has RAM for 132 columns, but only 128 pixels, so offset by 2 to center.
      def ram_x_offset
        @ram_x_offset ||= self.class.const_get("RAM_X_OFFSET")
      end

      def draw_partial(buffer, x_start, x_finish, p_start, p_finish, color=1)
        x = x_start + ram_x_offset
        x_lower = (x & 0b00001111)
        x_upper = (x & 0b11110000) >> 4

        (p_start..p_finish).each do |page|
          # Set the page and column to start writing at.
          command [PAGE_START | page, COLUMN_START_LOWER | x_lower, COLUMN_START_UPPER | x_upper]

          # Get needed bytes for this page only.
          src_start       = (columns * page) + x_start
          src_end         = (columns * page) + x_finish
          partial_buffer  = buffer[src_start..src_end]

          # Send in chunks up to maximum transfer size.
          partial_buffer.each_slice(transfer_limit) { |slice| data(slice) }
        end
      end
    end
  end
end
