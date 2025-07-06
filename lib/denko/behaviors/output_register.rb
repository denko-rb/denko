module Denko
  module Behaviors
    module OutputRegister
      include BoardProxy
      include Lifecycle

      BYTE_COUNT = 1

      after_initialize do
        state
      end

      def bytes
        @bytes = params[:bytes] || self.class::BYTE_COUNT
      end

      def state
        @state ||= Array.new(bytes) { 0 }
      end

      def write
        raise ArgumentError, "#write not implemented in including class, for Behaviors::OutputRegister"
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
    end
  end
end
