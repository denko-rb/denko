module Denko
  module RTC
    class DS3231
      include I2C::Peripheral

      I2C_ADDRESS = 0x68

      # Write start register 0x00, then bytes to set time.
      def time=(time)
        i2c_write [0] + time_to_bcd(time)
        time
      end

      # Do a blocking read when #time is called.
      alias :time :read

      # Time data starts at register 0 and is 7 bytes long.
      def _read
        i2c_read(7, register: 0)
      end

      def pre_callback_filter(bytes)
        bcd_to_time(bytes)
      end

      # Convert Time object to 7 byte BCD sequence.
      def time_to_bcd(time)
        wday = time.wday
        wday = 7 if wday == 0

        [ BCD.decode(time.sec),
          BCD.decode(time.min),
          BCD.decode(time.hour),
          BCD.decode(wday),
          BCD.decode(time.day),
          BCD.decode(time.month),
          BCD.decode(time.year - 1970) ]
      end

      # Convert 7 byte BCD sequence to Time object.
      def bcd_to_time(bytes)
        t = bytes.map { |b| BCD.encode(b) }
        Time.new t[6] + 1970, t[5], t[4], t[2], t[1], t[0]
      end
    end
  end
end
