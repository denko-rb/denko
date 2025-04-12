module Denko
  module Display
    class SSD1306
      include MonoOLED

      def draw_partial(buffer, x_min, x_max, p_min, p_max)
        # Limit auto-incrementing GRAM address to the rectangle being drawn.
        command [ COLUMN_ADDRESS_RANGE, x_min, x_max, PAGE_ADDRESS_RANGE, p_min, p_max ]

        # Send all the bytes at once if within board I2C limit.
        if buffer.length < (bus.board.i2c_limit - 1)
          data(buffer)

        # Or split into chunks.
        else
          buffer.each_slice(bus.board.i2c_limit - 1) { |slice| data(slice) }
        end
      end
    end
  end
end
