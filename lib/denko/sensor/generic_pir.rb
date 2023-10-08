module Denko
  module Sensor
    class GenericPIR < DigitalIO::Input
      alias :on_motion_stop  :on_low
      alias :on_motion_start :on_high
    end
  end
end
