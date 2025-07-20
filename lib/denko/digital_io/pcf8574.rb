module Denko
  module DigitalIO
    class PCF8574
      include I2C::Peripheral
      include Behaviors::OutputRegister
      include Behaviors::Lifecycle

      # Default I2C address. Override with i2c_address: key in initialize hash.
      I2C_ADDRESS   = 0x3F
      I2C_FREQUENCY = 400_000

      # 8 bit I/O expander, where each I2C read/write gets/sets everyhing.
      # No separate data direction register. See #set_pin_mode below.
      BYTES = 1

      def platform
        :pcf8574
      end

      after_initialize do
        read_state
      end

      # Gives actual state of the pins, regardless of direction.
      def read_state
        @state = i2c_read_raw(1)
      end

      # Called by Beaviors::OutputRegister to write @state.
      def _write(bytes)
        i2c_write(bytes)
      end

      # Writing 1 is high-impedance mode. Pin behaves as input or high output.
      # Writing 0 is low output.
      def set_pin_mode(pin, mode, options={})
        if mode == :output
          digital_write(pin, 0)
        else
          digital_write(pin, 1)
        end
      end
    end
  end
end
