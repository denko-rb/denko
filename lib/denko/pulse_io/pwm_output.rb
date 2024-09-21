module Denko
  module PulseIO
    class PWMOutput < DigitalIO::Output
      interrupt_with :write

      attr_reader :pwm_enabled

      def initialize_pins(options={})
        super(options)
        @pwm_enabled = false
      end

      def pwm_enable
        self.mode = :output_pwm
        @pwm_enabled = true
      end

      def pwm_disable
        self.mode = :output
        @pwm_enable = false
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
