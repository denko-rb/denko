module Denko
  module PulseIO
    class PWMOutput < DigitalIO::Output
      include Behaviors::Lifecycle

      interrupt_with :write

      def frequency
        @frequency ||= params[:frequency] || 1000
      end

      def resolution
        @resolution ||= params[:resolution] || board.analog_write_resolution
      end

      def pwm_high
        @pwm_high ||= (2**resolution-1)
      end

      attr_writer :frequency

      def resolution=(value)
        @resolution = value
        @pwm_high = (2**value-1)
      end

      def pwm_settings_hash
        { frequency: frequency, resolution: resolution }
      end

      def pwm_enabled
        @mode == :output_pwm
      end

      def pwm_enable(frequency: nil, resolution: nil)
        self.frequency  = frequency  if frequency
        self.resolution = resolution if resolution
        board.set_pin_mode(pin, :output_pwm, pwm_settings_hash)
        @mode = :output_pwm
      end

      def pwm_disable
        self.mode = :output
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
    end
  end
end
