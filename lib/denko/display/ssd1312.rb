module Denko
  module Display
    class SSD1312
      include MonoOLED
      include Behaviors::Lifecycle

      # Reverse default reflection.
      after_initialize do
        reflect_x
      end
    end
  end
end
