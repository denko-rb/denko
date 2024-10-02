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

    module PressureHelper
      def pressure
        state[:pressure]
      end

      def pressure_atm
        pressure / 101325.0
      end

      def pressure_bar
        pressure / 100000.0
      end
    end

    module HumidityHelper
      def humidity
        state[:humidity]
      end
    end
  end
end
