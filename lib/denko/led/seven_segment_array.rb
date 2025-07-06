module Denko
  module LED
    module SevenSegmentArray
      include Behaviors::BoardProxy
      include Behaviors::Lifecycle

      after_initialize do
        @rotated = params[:rotated] || params[:rotate]
      end
      attr_reader :rotated

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

      PUNCTUATION = [".", ":"]

      def text(str)
        # Split into either single chars, or pair of char + displayable punctuation mark.
        chars = []
        index = 0
        while chars.length < digits.count
          char = str[index]
          index += 1
          if PUNCTUATION.include? str[index]
            char << str[index]
            index += 1
          end
          chars << char
        end

        # Move colon to next digit, so it shows when rotated. Ignore decimal points.
        if rotated
          chars.reverse!
          chars.each_with_index do |char, i|
            if (char[1] == ":") && (i > 0)
              chars[i] = char[0]
              chars[i-1][1] = ":"
            end
          end
          chars.reverse!
        end

        digits.each_with_index { |d, i| d.write(chars[i], soft: true) }
        write
      end
    end
  end
end
