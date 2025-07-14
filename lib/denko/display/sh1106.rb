module Denko
  module Display
    class SH1106
      include MonoOLED

      # 132 bytes per page, with central 128 connected to column lines. Start on 2.
      RAM_X_OFFSET = 2
    end
  end
end
