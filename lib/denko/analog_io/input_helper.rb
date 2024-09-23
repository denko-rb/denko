module Denko
  module AnalogIO
    module InputHelper
      #
      # Smoothing features.
      # Does a moving average of the last smoothing_size readings.
      #
      attr_accessor :smoothing, :smoothing_size

      def smoothing_size
        @smoothing_size ||= 8
      end

      def smoothing_set
        @smoothing_set ||= []
      end

      def smooth_input(value)
        # Add new value, but limit to the 8 latest values.
        smoothing_set << value
        smoothing_set.shift while (smoothing_set.length > smoothing_size)

        average = smoothing_set.reduce(:+) / smoothing_set.length.to_f

        # Round up or down based on previous state to reduce fluctuations.
        state && (state > average) ? average.ceil : average.floor
      end

      # Handle smoothing if enabled. Call super(value) after conversion in subclasses.
      def pre_callback_filter(value)
        smoothing ? smooth_input(value.to_i) : value.to_i
      end

      # Attach a callback that only fires when state changes.
      def on_change(&block)
        add_callback(:on_change) do |new_state|
          block.call(new_state) if new_state != self.state
        end
      end
    end
  end
end
