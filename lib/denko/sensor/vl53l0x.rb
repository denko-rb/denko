module Denko
  module Sensor
    class VL53L0X
      include I2C::Peripheral
      include Behaviors::Poller
      include Behaviors::Lifecycle

      I2C_ADDRESS = 0x29

      REFERENCE_REGISTER_START = 0xC0
      REFERENCE_VALUES = [0xEE, 0xAA, 0x10]

      SYSRANGE_START = 0x00
      POWER_MANAGEMENT_GO1_POWER_FORCE = 0x80
      INTERNAL_TUNING_1 = 0x91
      INTERNAL_TUNING_2 = 0xFF
      RESULT_RANGE_STATUS = 0x14

      attr_reader :stop_variable
      attr_accessor :correction_offset

      after_initialize do
        # Verify reference registerrs
        reference_regs = i2c_read_blocking(REFERENCE_VALUES.length, register: REFERENCE_REGISTER_START)
        raise "reference registers do not match. May not be VL53L0X" unless reference_regs == REFERENCE_VALUES

        # Initialization sequence
        @stop_variable = i2c_read_blocking(1, register: INTERNAL_TUNING_1)[0]
        i2c_write [POWER_MANAGEMENT_GO1_POWER_FORCE, 0x01]
        i2c_write [INTERNAL_TUNING_2, 0x01]
        i2c_write [SYSRANGE_START, 0x00]
        i2c_write [INTERNAL_TUNING_1, stop_variable]
        i2c_write [SYSRANGE_START, 0x01]
        i2c_write [INTERNAL_TUNING_2, 0x00]
        i2c_write [POWER_MANAGEMENT_GO1_POWER_FORCE, 0x00]

        # Wait for initialization to complete.
        sleep 0.010 while (i2c_read_blocking(1, register: SYSRANGE_START)[0] & 0b01 > 0)

        # Go into continuous mode.
        i2c_write [SYSRANGE_START, 0x02]
      end

      def _read
        add_callback(:read_range)
        i2c_read(2, register: RESULT_RANGE_STATUS + 10)
      end

      def pre_callback_filter(bytes)
        return bytes unless callbacks[:read_range]

        # Distance is 2 bytes, big-endian.
        remove_callback(:read_range)
        mm = (bytes[0] << 8) | bytes[1]
        mm = mm + correction_offset if correction_offset
        return (mm > 0) ? mm : nil
      end
    end
  end
end
