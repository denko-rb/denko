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

        params[:mode] = :input_adc
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

      if Denko.mruby?
        # Optimized to bypass *args and **kwargs. Behaves like CRuby.
        def read(&block)
          board.analog_read(@pin, @negative_pin, @gain, @sample_rate)
          # board calls #update on us here.
          block.call(@read_result) if block_given?
          @read_result
        end

        # Bypasses *args, **kwargs, &block, #update, @read_result and @state.
        def read_raw
          board.analog_read_raw(@pin)
        end
      end

      def _listen(divider=nil)
        @divider = divider || @divider
        board.analog_listen(@pin, @divider)
      end
    end
  end
end
