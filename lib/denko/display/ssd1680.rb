module Denko
  module Display
    class SSD1680 < SSD168X
      COLUMNS = 296
      ROWS    = 128

      # SSD1680 needs an extra byte here to offset source start by 8 pixels.
      def set_display_update_control
        super
        data [0b1000_0000]
      end
    end
  end
end
