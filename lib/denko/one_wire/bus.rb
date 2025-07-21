module Denko
  module OneWire
    class Bus < DigitalIO::CBitBang
      include Behaviors::BusControllerAddressed
      include Behaviors::Reader
      include Behaviors::Lifecycle
      include BusEnumerator
      include Constants

      attr_reader :parasite_power

      after_initialize do
        read_power_supply
      end

      def read_power_supply
        mutex.lock

        # Without driving low first, results are inconsistent.
        board.set_pin_mode(self.pin, :output)
        board.digital_write(self.pin, board.low)
        sleep 0.1

        reset
        write(SKIP_ROM, READ_POWER_SUPPLY)

        # Only LSBIT matters, but we can only read whole bytes.
        byte = read(1)
        @parasite_power = (byte & 0b1 == 0) ? true : false

        mutex.unlock
        @parasite_power
      end

      def device_present
        mutex.lock
        byte = read_using -> { reset(true) }
        presence = (byte == 0) ? true : false
        mutex.unlock
        presence
      end
      alias :device_present? :device_present

      def reset(get_presence=false)
        board.one_wire_reset(pin, get_presence)
      end

      def read(num_bytes, &block)
        @read_type = :regular
        board.one_wire_read(@pin, num_bytes)

        sleep READ_WAIT_TIME while (@read_type != :idle)
        block.call(@read_result) if block_given?
        @read_result
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
