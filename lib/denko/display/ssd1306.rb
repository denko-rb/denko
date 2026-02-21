module Denko
  module Display
    class SSD1306
      include MonoOLED
      include Behaviors::Lifecycle

      after_initialize do
        @ram_x_offset = 32 if (columns == 64)
      end
    end
  end
end
