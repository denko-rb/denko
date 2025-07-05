module Denko
  module UART
    class Hardware
      include Behaviors::SinglePin
      include Behaviors::Callbacks
      include Behaviors::Lifecycle
      include Common

      DEFAULT_BAUD   = 9600
      DEFAULT_CONFIG = "8N1"

      attr_reader :index, :baud, :config

      before_initialize do
        raise ArgumentError, "UART index (#{params[:index]}) out of range (1..3)" unless (1..3).include?(params[:index])

        @index = params[:index]
        # Set pin to corresponding "virtual pin" in range 251..253, to receive reads.
        params[:pin] = 250 + @index
      end

      after_initialize do
        initialize_buffer
        start(params[:baud], params[:config])
      end

      def start(b, c=nil)
        @baud   = b || DEFAULT_BAUD
        @config = c || DEFAULT_CONFIG

        board.uart_start(index, baud, config, true)
      end

      def stop()
        board.uart_stop(index)
      end

      def write(data)
        board.uart_write(index, data)
      end
    end
  end
end
