module Denko
  module AnalogIO
    class Input
      include Behaviors::InputPin
      include Behaviors::Poller
      include Behaviors::Listener
      include InputHelper
      include Behaviors::Lifecycle

      before_initialize do
        # Allow giving ADC unit with multiple pins as a board proxy.
        if params[:adc]
          params[:board] = params[:adc]
          params.delete(:adc)
        end
      end

      after_initialize do
        # Default 16ms listener for analog inputs connected to a Board.
        @divider = params[:divider] || 16

        # Negative input on ADCs that support it.
        @negative_pin = params[:negative_pin]

        # PGA gain for ADCs that support it
        @gain = params[:gain]

        # Sample rate for ADCs that support it.
        @sample_rate = params[:sample_rate]
      end

      attr_accessor :divider, :negative_pin, :gain, :sample_rate

      # Allow ADCs to set this, so exact voltages can be calculated.
      attr_accessor :volts_per_bit

      def _read
        board.analog_read(@pin, @negative_pin, @gain, @sample_rate)
      end

      # Optimized #read instead of Behaviors::Reader default.
      if Denko.mruby?
        def read
          board.analog_read(@pin, @negative_pin, @gain, @sample_rate)
          @read_result
        end
      else
        def read
          sleep READ_WAIT_TIME while (@read_type != :idle)
          @read_type = :regular
          board.analog_read(@pin, @negative_pin, @gain, @sample_rate)
          sleep READ_WAIT_TIME while (@read_type != :idle)
          @read_result
        end
      end

      def _listen(div=nil)
        @divider = div if div
        board.analog_listen(@pin, @divider)
      end
    end
  end
end
