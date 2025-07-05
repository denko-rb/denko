module Denko
  module LED
    module SevenSegmentArray
      #
      # BoardProxy interface
      #
      include Denko::Behaviors::BoardProxy

      def state
        @state ||= Array.new(self.class::BYTE_COUNT) { 0 }
      end

      def digital_write(pin, value)
        bit_set(pin, value)
        write
      end

      def bit_set(pin, value)
        byte = pin / 8
        bit  = pin % 8

        @state_mutex.lock
          if value == 0
            @state[byte] &= ~(0b1 << bit)
          else
            @state[byte] |= (0b1 << bit)
          end
        @state_mutex.unlock

        value
      end

      def digital_read(pin)
        byte = pin / 8
        bit  = pin % 8

        (state[byte] >> bit) & 0b1
      end

      def pin_is_pwm?(pin)
        false
      end

      #
      # LED array interface
      #
      attr_reader :digits, :colon

      def text(str)
        digits.each_with_index do |digit, i|
          digit.write(str[i], soft: true)
        end
        write
      end
    end
  end
end
