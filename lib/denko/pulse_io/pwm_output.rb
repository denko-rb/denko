module Denko
  module PulseIO
    class PWMOutput < DigitalIO::Output
      interrupt_with :write

      attr_reader :resolution, :frequency, :pwm_high

      def after_initialize(options={})
        @frequency  = options[:frequency]  || nil
        @resolution = options[:resolution] || nil
        @pwm_high   = @resolution ? (2**@resolution-1) : board.pwm_high
        super(options)
      end

      def pwm_options
        {frequency: @frequency, resolution: @resolution}
      end

      def pwm_enabled
        @mode == :output_pwm
      end

      def pwm_enable(frequency: nil, resolution: nil)
        @frequency  = frequency if frequency
        if resolution
          @resolution = resolution
          @pwm_high = 2**@resolution-1
        end
        board.set_pin_mode(pin, :output_pwm, pwm_options)
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
