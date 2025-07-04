module Denko
  module Behaviors
    module BoardProxy
      include Subcomponents

      def platform
        :proxy
      end

      def high
        1
      end

      def low
        0
      end

      def analog_read_high
        nil
      end

      def analog_write_high
        nil
      end

      alias :pwm_high :analog_write_high
      alias :dac_high :analog_write_high
      alias :adc_high :analog_read_high

      def convert_pin(pin)
        pin.to_i
      end

      def set_pin_mode(pin, mode, options={}); end

      def start_read; end

      def bit_set(pin, value)
        raise NotImplementedError, "#bit_set not implemented for #{self.class}"
      end
    end
  end
end
