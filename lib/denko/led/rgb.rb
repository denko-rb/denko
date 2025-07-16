module Denko
  module LED
    class RGB
      include Behaviors::MultiPin

      def initialize_pins
        proxy_pin :red,   LED::Base
        proxy_pin :green, LED::Base
        proxy_pin :blue,  LED::Base
      end

      # Format: [R, G, B]
      COLORS = {
        red:     [100, 000, 000],
        green:   [000, 100, 000],
        blue:    [000, 000, 100],
        cyan:    [000, 100, 100],
        yellow:  [100, 100, 000],
        magenta: [100, 000, 100],
        white:   [100, 100, 100],
        off:     [000, 000, 000]
      }

      def write(r, g, b)
        red.duty   = r
        green.duty = g
        blue.duty  = b
      end

      def write_8_bit(r, g, b)
        red.duty   = ((r / 255.0) * 100).round
        green.duty = ((g / 255.0) * 100).round
        blue.duty  = ((b / 255.0) * 100).round
      end

      def color=(color)
        color = color.to_sym
        write(*COLORS[color]) if COLORS.include? color
      end
    end
  end
end
