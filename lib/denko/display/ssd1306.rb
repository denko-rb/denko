module Denko
  module Display
    class SSD1306
      include MonoOLED

      def draw_partial(buffer, x_start, x_finish, p_start, p_finish)
        # Limit auto-incrementing GRAM address to the rectangle being drawn.
        command [ COLUMN_ADDRESS_RANGE, x_start, x_finish, PAGE_ADDRESS_RANGE, p_start, p_finish ]

        # Send in chunks up to maximum transfer size.
        buffer.each_slice(transfer_limit) { |slice| data(slice) }
      end
    end
  end
end
