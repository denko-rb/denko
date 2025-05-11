module Denko
  module Display
    class SSD1680 < SSD1681
      COLUMNS = 296
      ROWS    = 128

      # SSD1680 needs an extra byte here to offset source start by 8 pixels.
      def set_display_update_control
        # Need to invert black. Ignore red for now.
        command [DISPLAY_UPDATE_CTL1]
        data    [0b0100_1000, 0b10000000]
      end
    end
  end
end
