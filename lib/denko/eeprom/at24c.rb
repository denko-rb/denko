module Denko
  module EEPROM
    class AT24C
      include I2C::Peripheral

      I2C_ADDRESS     = 0x50
      I2C_FREQUENCY   = 400_000
      READ_WRITE_US   = 20_000
      WRITE_PAGE_SIZE = 64

      def int_to_reg_array(int)
        [ (int >> 8) & 0xFF, int & 0xFF ]
      end

      def [](loc)
        if loc.class == Range
          index  = loc.first
          count  = loc.count
          limit  = bus.board.i2c_limit
          result = []

          # Chunked reads based on Board#i2c_limit.
          # Reading appears to cross page borders seamlessly.
          while count > 0
            this_count = (count > limit) ? limit : count
            result += i2c_read_raw(this_count, register: int_to_reg_array(index))
            index = index + this_count
            count = count - this_count
          end

          result
        else
          i2c_read_raw(1, register: int_to_reg_array(loc))
        end
      end

      def []=(loc, value)
        if value.class == Array
          # Start address uses up 2 bytes.
          limit = bus.board.i2c_limit - 2

          remaining = value.length
          src_start = 0
          dst_start = loc

          while remaining > 0
            # Limit to lowest of: remaining page size, I2C max size, or remaining bytes.
            size = WRITE_PAGE_SIZE - (dst_start % WRITE_PAGE_SIZE)
            size = limit if (limit < size)
            size = remaining if (remaining < size)
            src_end = src_start + size - 1

            i2c_write(int_to_reg_array(dst_start) + value[src_start..src_end])
            micro_delay(READ_WRITE_US)

            remaining -= size
            src_start += size
            dst_start += size
          end
        else
          i2c_write(int_to_reg_array(loc) + [value])
          micro_delay(READ_WRITE_US)
        end
      end
    end
  end
end
