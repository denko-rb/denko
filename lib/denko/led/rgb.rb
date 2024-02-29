module Denko
  module LED
    class RGB
      include Behaviors::MultiPin

      def initialize_pins(options={})
        proxy_pin :red,   LED::Base
        proxy_pin :green, LED::Base
        proxy_pin :blue,  LED::Base
      end

      # Format: [R, G, B]
      COLORS = {
        red:     [255, 000, 000],
        green:   [000, 255, 000],
        blue:    [000, 000, 255],
        cyan:    [000, 255, 255],
        yellow:  [255, 255, 000],
        magenta: [255, 000, 255],
        white:   [255, 255, 255],
        off:     [000, 000, 000]
      }

      def write(r, g, b)
        red.write(r)
        green.write(g)
        blue.write(b)
      end

      def color=(color)
        color = color.to_sym
        write(*COLORS[color]) if COLORS.include? color
      end
    end
  end
end
