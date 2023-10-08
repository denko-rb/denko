module Denko
  module Sensor
    class AS312 < DigitalIO::Input
      alias :on_motion_stop  :on_low
      alias :on_motion_start :on_high
    end
  end
end
