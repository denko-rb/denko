module Denko
  module PulseIO
    class PWMOutput < DigitalIO::Output
      include Behaviors::Lifecycle

      interrupt_with :write, :pwm_write, :digital_write, :duty=

      # Avoid setting :output mode if on PWM pin, and on a platform that muxes externally.
      before_initialize do
        b = params[:board]
        p = params[:pin]
        params[:mode] = :output_pwm if b.platform != :arduino && b.pin_is_pwm?(p)
      end

      # Call #pwm_enable immediately if params[:mode] was overriden to :output_pwm.
      after_initialize do
        pwm_enable if params[:mode] == :output_pwm
      end

      def duty=(percent)
        if board.platform == :arduino
          pwm_write((percent / 100.0 * pwm_high).round)
        else
          pwm_write((percent / 100.0 * period).round)
        end
      end

      def digital_write(value)
        # Use regular #digital_write for speed until a PWM method is called.
        unless pwm_enabled?
          super(value)
        else
          # On Arduinos, disable PWM and switch back to regular #digital_write.
          if board.platform == :arduino
            pwm_disable
            super(value)
          # Can't do that on Linux, so mimic DigitalIO.
          else
            if value == 1
              pwm_write(period)
            else
              pwm_write(0)
            end
          end
        end
      end

      # Raw write. Takes nanoseconds on Linux, 0..pwm_high on Arduino.
      def pwm_write(value)
        pwm_enable unless pwm_enabled?
        board.pwm_write(pin, value)
        self.state = value
      end
      alias :write :pwm_write

      def frequency
        @frequency ||= params[:frequency] || 1000
      end

      def period
        @period ||= (1_000_000_000.0 / frequency).round
      end

      def resolution
        @resolution ||= params[:resolution] || board.analog_write_resolution
      end

      def pwm_high
        @pwm_high ||= (2**resolution-1)
      end

      def _frequency=(value)
        @frequency = value
        @period    = nil
      end

      def _resolution=(value)
        @resolution = value
        @pwm_high   = nil
      end

      def frequency=(value)
        self._frequency = value
        pwm_enable
      end

      def resolution=(value)
        self._resolution = value
        pwm_enable
      end

      def pwm_settings_hash
        { frequency: frequency, period: period, resolution: resolution }
      end

      def pwm_enable(frequency: nil, resolution: nil)
        self._frequency  = frequency if frequency
        self._resolution = resolution if resolution

        board.set_pin_mode(pin, :output_pwm, pwm_settings_hash)
        @mode = :output_pwm
      end

      def pwm_disable
        self.mode = :output if board.platform == :arduino
      end

      def pwm_enabled?
        self.mode == :output_pwm
      end
    end
  end
end
