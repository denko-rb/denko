module Denko
  module EEPROM
    class AT24C
      include I2C::Peripheral

      I2C_ADDRESS     = 0x50
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

          # Chunked reads based on Board#i2c_limit
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
          index = loc
          limit = bus.board.i2c_limit - 2

          value.each_slice(WRITE_PAGE_SIZE) do |page|
            page.each_slice(limit) do |slice|
              i2c_write(int_to_reg_array(index) + slice)
              micro_delay(READ_WRITE_US)
              index += slice.length
            end
          end
        else
          i2c_write(int_to_reg_array(loc) + [value])
          micro_delay(READ_WRITE_US)
        end
      end
    end
  end
end
