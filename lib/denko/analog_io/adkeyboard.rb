module Denko
  module AnalogIO
    class ADKeyboard < Input
      include Behaviors::InputRegister
      include Behaviors::Lifecycle

      BYTES = 1

      # All virtual "pins" high by default.
      UNPRESSED_STATE = [0b11111]

      # Threshold voltages (as percent of board.adc_high) for each button.
      ADC_THRESHOLDS = [0.04, 0.18, 0.34, 0.56, 0.78]

      attr_reader :buttons

      after_initialize do
        @pre_callback_temp_array = [0]
        @adc_high_f = board.adc_high.to_f

        # PCB print has buttons 1-indexed, but 0-index them here.
        @buttons = []
        (0..4).each do |index|
          @buttons << Denko::DigitalIO::Button.new(board: self, pin: index)
        end
      end

      def pre_callback_filter(value)
        button = nil
        percent = value.to_i / @adc_high_f

        # Only one button press can be detected at a time.
        # Lowest voltage overrides others.
        ADC_THRESHOLDS.each_with_index do |threshold, index|
          if percent <= threshold
            button = index
            break
          end
        end

        if button
          @pre_callback_temp_array[0] = (0b1 << button) ^ UNPRESSED_STATE[0]
          return @pre_callback_temp_array
        elsif (@state != UNPRESSED_STATE)
          return UNPRESSED_STATE
        else
          return nil
        end
      end
    end
  end
end
