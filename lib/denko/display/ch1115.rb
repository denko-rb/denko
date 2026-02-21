module Denko
  module Display
    class CH1115
      include MonoOLED
      COLUMNS = 88
      ROWS    = 48
      RAM_P_OFFSET = 1

      # Deal with unusual memory layout.
      def reflect_x
        @ram_x_offset = (@ram_x_offset == 0) ? 40 : 0
        super
      end

      def reflect_y
        @ram_p_offset = (@ram_p_offset == 1) ? 0 : 1
        super
      end
    end
  end
end
