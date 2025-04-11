module Denko
  module UART
    class Hardware
      include Behaviors::SinglePin
      include Behaviors::Callbacks
      include Behaviors::Lifecycle
      include Common

      attr_reader :index, :baud

      before_initialize do
        if params[:index] && (params[:index] > 0) && (params[:index] < 4)
          @index = params[:index]
        else
          raise ArgumentError, "UART index (#{params[:index]}) not given or out of range (1..3)"
        end

        # Set pin to a "virtual pin" in 251 - 253 that will match the board.
        params[:pin] = 250 + params[:index]
      end

      after_initialize do
        initialize_buffer
        start(params[:baud] ||= 9600)
      end

      def start(baud)
        @baud = baud
        board.uart_start(index, baud, true)
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
