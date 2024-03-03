module Denko
  module Sensor
    module TemperatureHelper
      def temperature
        state[:temperature]
      end

      def temperature_f
        (temperature * 1.8 + 32).round(4)
      end

      def temperature_k
        temperature + 273.15
      end
    end
  end
end
