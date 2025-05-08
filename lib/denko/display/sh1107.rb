module Denko
  module Display
    class SH1107 < SH1106
      COLUMNS = 128
      ROWS    = 128

      # SH1107 RAM has 128 columns, unlike 132 on SH1106. Don't offset by 2.
      def ram_x_offset
        0
      end
    end
  end
end
