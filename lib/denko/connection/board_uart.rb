module Denko
  module Connection
    class BoardUART < Base
      DEFAULT_BAUD = 115200

      def initialize(uart, baud: DEFAULT_BAUD)
        @uart = uart
        @uart.start(baud)
      end

      def baud
        @uart.baud
      end

      def flush_read
        @uart.flush
      end

      def to_s
        "#{@uart} @ #{@uart.baud} baud"
      end

      def _write(message)
        io.write(message)
      end

      def _read
        io.gets
      end

      def connect
        @uart
      end
    end
  end
end
