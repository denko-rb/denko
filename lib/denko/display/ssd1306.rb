module Denko
  module Display
    class SSD1306
      include MonoOLED

      def draw_partial(buffer, x_min, x_max, p_min, p_max)
        # Limit auto-incrementing GRAM address to the rectangle being drawn.
        command [ COLUMN_ADDRESS_RANGE, x_min, x_max, PAGE_ADDRESS_RANGE, p_min, p_max ]

        # Send in chunks up to maximum transfer size.
        buffer.each_slice(transfer_limit) { |slice| data(slice) }
      end
    end
  end
end
