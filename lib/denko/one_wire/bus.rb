module Denko
  module OneWire
    class Bus
      include Behaviors::Component
      include Behaviors::SinglePin
      include Behaviors::BusControllerAddressed
      include Behaviors::Reader
      include BusEnumerator
      include Constants

      attr_reader :parasite_power

      after_initialize do
        # Set input mode to force upfront pin validation.
        self.mode = :input

        read_power_supply
      end

      def read_power_supply
        mutex.synchronize do
          # Without driving low first, results are inconsistent.
          board.set_pin_mode(self.pin, :output)
          board.digital_write(self.pin, board.low)
          sleep 0.1

          reset
          write(SKIP_ROM, READ_POWER_SUPPLY)

          # Only LSBIT matters, but we can only read whole bytes.
          byte = read(1)
          @parasite_power = (byte[0] == 0) ? true : false
        end
      end

      def device_present
        mutex.synchronize do
          byte = read_using -> { reset(1) }
          (byte == 0) ? true : false
        end
      end
      alias :device_present? :device_present

      def reset(get_presence=0)
        board.one_wire_reset(pin, get_presence)
      end

      def _read(num_bytes)
        board.one_wire_read(pin, num_bytes)
      end

      def write(*bytes)
        bytes.flatten!
        pp = parasite_power && [CONVERT_T, COPY_SCRATCH].include?(bytes.last)
        board.one_wire_write(pin, pp, bytes)
      end

      def pre_callback_filter(bytes)
        # C extensions respond with Ruby array
        # External Board responds with comma delimited String
        unless bytes.class == Array
          bytes = bytes.split(",").map(&:to_i)
        end

        bytes.length > 1 ? bytes : bytes[0]
      end
    end
  end
end
