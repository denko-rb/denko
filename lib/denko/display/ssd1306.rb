module Denko
  module Display
    class SSD1306
      include MonoOLED
      include Behaviors::Lifecycle

      after_initialize do
        @ram_x_offset = 32 if (columns == 64)
        @ram_x_offset = 28 if (columns == 72)
      end
    end
  end
end
