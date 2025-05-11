module Denko
  module Display
    class SSD1680 < SSD168X
      COLUMNS = 296
      ROWS    = 128

      # SSD1680 needs an extra byte here to offset source start by 8 pixels.
      def set_display_update_control
        if colors == 1
          value = 0b0100_1000 # bypass red, invert black buffer
        else
          value = 0b0000_1000 # normal red, invert black buffer
        end

        command [DISPLAY_UPDATE_CTL1]
        data    [value, 0b10000000]
      end
    end
  end
end
