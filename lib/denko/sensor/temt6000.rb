module Denko
  module Sensor
    class TEMT6000 < AnalogIO::Input
      # 2 lux per micro amp, from datasheet: Typical Characteristics
      LUX_PER_AMP = 2_000_000

      attr_accessor :loading_resistance

      after_initialize do
        raise ArgumentError, "missing :vcc in params for ALSPT19" unless params[:vcc]
        self.vcc = params[:vcc]
        # 10k loading resistor, common on breakout boards
        self.loading_resistance = 10_000
      end

      def vcc=(v)
        @vcc = v.to_f
        self.volts_per_bit = @vcc / (@board.adc_high + 1)
      end

      def pre_callback_filter(value)
        amps = (value.to_i * volts_per_bit) / loading_resistance
        lux  = amps * LUX_PER_AMP
      end
    end
  end
end
