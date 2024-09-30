module Denko
  module PulseIO
    class PWMOutput < DigitalIO::Output
      include Behaviors::Lifecycle

      interrupt_with :write, :pwm_write, :digital_write, :duty=

      def duty=(percent)
        if board_is_piboard
          pwm_write(percent)
        else
          pwm_write(((percent * pwm_high) / 100.0).round)
        end
      end

      def digital_write(value)
        pwm_disable if pwm_enabled
        super(value)
      end

      def pwm_write(value)
        pwm_enable unless pwm_enabled
        board.pwm_write(pin, value)
        self.state = value
      end
      alias :write :pwm_write

      def frequency
        @frequency ||= params[:frequency] || 1000
      end

      def resolution
        @resolution ||= params[:resolution] || board.analog_write_resolution
      end

      def pwm_high
        @pwm_high ||= (2**resolution-1)
      end

      def frequency=(value)
        @frequency = value
        pwm_enable
      end

      def resolution=(value)
        @resolution = value
        @pwm_high   = (2**value-1)
        pwm_enable
      end

      def pwm_settings_hash
        { frequency: frequency, resolution: resolution }
      end

      def pwm_enable(frequency: nil, resolution: nil)
        @frequency  = frequency  if frequency
        if resolution
          @resolution = resolution
          @pwm_high   = (2**resolution-1)
        end

        board.set_pin_mode(pin, :output_pwm, pwm_settings_hash)
        @mode = :output_pwm
      end

      def pwm_disable
        self.mode = :output
      end

      def pwm_enabled
        mode == :output_pwm
      end

      def board_is_piboard
        @board_is_piboard ||= piboard_check
      end

      def piboard_check
        if Object.const_defined?("Denko::PiBoard")
          if board.class.ancestors.include?(Denko::PiBoard)
            return true
          end
        end
        false
      end
    end
  end
end
