module Denko
  module Behaviors
    module OutputRegister
      include Register
      include Lifecycle

      def write
        if @state != @old_state
          # Including classes must implement #_write.
          _write(@state)
          @state.each_with_index { |byte, i| @old_state[i] = byte }
        end
        state
      end

      def digital_write(pin, value)
        bit_set(pin, value)
        write
      end

      def bit_set(pin, value)
        byte = pin / 8
        bit  = pin % 8

        if value == 0
          @state[byte] &= ~(0b1 << bit)
        else
          @state[byte] |= (0b1 << bit)
        end

        value
      end

      def digital_read(pin)
        byte = pin / 8
        bit  = pin % 8

        (state[byte] >> bit) & 0b1
      end
    end
  end
end
