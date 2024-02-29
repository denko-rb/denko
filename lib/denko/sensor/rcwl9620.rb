module Denko
  module Sensor
    class RCWL9620
      include I2C::Peripheral
      include Behaviors::Poller

      def before_initialize(options={})
        @i2c_address = 0x57
        super(options)
      end

      def _read
        i2c_write(0x01)
        sleep(0.120)
        i2c_read(3)
      end

      def pre_callback_filter(bytes)
        # Data is in micrometers, 3 bytes, big-endian.
        um = (bytes[0] << 16) + (bytes[1] << 8) + bytes[2]
        mm = um / 1000.0

        # Limit output between 20 and 4500mm.
        if mm > 4500.0
          return 4500.0
        elsif mm < 20.0
          return 20.0
        else
          return mm
        end
      end
    end
  end
end
