module Denko
  module DigitalIO
    class PCF8574
      include I2C::Peripheral
      include Behaviors::Lifecycle

      # Default I2C address. Override with i2c_address: key in initialize hash.
      I2C_ADDRESS   = 0x3F
      I2C_FREQUENCY = 400_000

      #
      # 8 bit I/O expander where each read/write is a single I2C byte that gets/sets the whole register.
      # - No separate data direction register.
      # - Writing 1 to a bit puts that pin into high-impedance mode. It behaves as input or high output.
      # - Writing 0 is low output.
      # - Reading gives the actual state of the pins, regardless of direction.
      #
      after_initialize do
        read_state
      end

      def write
        bytes = []
        @state_mutex.lock
        if @state != @previous_state
          @state.each_slice(8) do |slice|
            byte = 0
            slice.each_with_index do |bit, index|
              next unless bit
              byte |= (bit << index)
            end

            bytes.unshift byte
          end
          i2c_write bytes
          @previous_state = @state.dup
        end
        @state_mutex.unlock
        @state
      end

      def read_state
        @state_mutex.lock
        byte = i2c_read_raw(1)[0]
        8.times do |i|
          @state[i] = (byte >> i) & 0b1
        end
        @state_mutex.unlock
        @state
      end

      #
      # BoardProxy interface. Refactor maybe?
      #
      def platform
        :pcf8574
      end

      def set_pin_mode(pin, mode, options={})
        if mode == :output
          digital_write(pin, 0)
        else
          digital_write(pin, 1)
        end
      end

      def digital_read(pin)
        state[pin]
      end

      def is_a_register?
        true
      end

      #
      # Taken from SPI::BaseRegister
      #
      include Behaviors::BoardProxy
      #
      # Default registers to 1 byte, or 8 pins when used as Board Proxy.
      # Can be ignored if reading / writing the register directly.
      def bytes
        @bytes = params[:bytes] || 1
      end
      attr_writer :bytes
      #
      # When used as BoardProxy, store the state of each register
      # pin as a 0 or 1 in an array that is (@bytes * 8) long.
      #
      def state
        @state ||= Array.new(bytes*8) { 1 }
      end

      #
      # Taken from SPI::Output Register.
      #
      def digital_write(pin, value)
        bit_set(pin, value)
        write
      end

      def bit_set(pin, value)
        @state_mutex.lock
        @state[pin] = value
        @state_mutex.unlock
        value
      end

      def pin_is_pwm?(pin)
        false
      end
    end
  end
end
