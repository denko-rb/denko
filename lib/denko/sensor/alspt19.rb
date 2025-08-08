module Denko
  module Sensor
    class ALSPT19 < AnalogIO::Input
      # 0.1976 uA per lux, from datasheet Fig. 6
      LUX_PER_AMP = 1_000_000 / 0.1976

      # From datasheet Fig. 4, approximated to linear
      VCC_COMP_GRADIENT = 0.0236
      VCC_CUTOFF_LOW    = 2.0
      VCC_CUTOFF_HIGH   = 4.5
      VCC_TYPICAL       = 3.0

      # From datasheet Fig. 5, appromximated to linear
      TEMP_COMP_GRADIENT =   0.035
      TEMP_CUTOFF_LOW    = -40.0
      TEMP_CUTOFF_HIGH   =  85.0
      TEMP_TYPICAL       =  25.0

      after_initialize do
        raise ArgumentError, "missing :vcc in params for ALSPT19" unless params[:vcc]
        self.vcc = params[:vcc]
        self.temperature = 25
        # 10k loading resistor on common breakout boards
        self.loading_resistance = 10_000
      end

      def loading_resistance=(ohms)
        @loading_resistance = ohms
      end

      def temperature=(t)
        @temperature = t.to_f
        set_temp_compensator
      end

      def vcc=(v)
        @vcc = v.to_f
        self.volts_per_bit = @vcc / (@board.adc_high + 1)
        set_vcc_compensator
      end

      private

      def set_vcc_compensator
        vcc_calc = @vcc
        vcc_calc = VCC_CUTOFF_HIGH if vcc_calc >= VCC_CUTOFF_HIGH
        vcc_calc = VCC_CUTOFF_LOW  if vcc_calc <= VCC_CUTOFF_LOW
        @vcc_compensator = 1.0 + ((vcc_calc - VCC_TYPICAL) * VCC_COMP_GRADIENT)
      end

      def set_temp_compensator
        temp_calc = @temperature
        temp_calc = TEMP_CUTOFF_HIGH if temp_calc >= TEMP_CUTOFF_HIGH
        temp_calc = TEMP_CUTOFF_LOW  if temp_calc <= TEMP_CUTOFF_LOW
        @temp_compensator = 1.0 + ((temp_calc - TEMP_TYPICAL) * TEMP_COMP_GRADIENT)
      end

      def pre_callback_filter(value)
        amps = (value.to_i * volts_per_bit) / @loading_resistance
        lux  = amps * LUX_PER_AMP * @vcc_compensator * @temp_compensator
      end
    end
  end
end
