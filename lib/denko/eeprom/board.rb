module Denko
  module EEPROM
    class Board
      include Behaviors::Component
      include Behaviors::Reader

      def max_eeperom_txn
        @max_eeeprom_txn ||= board.aux_limit - 3
      end

      def length
        board.eeprom_length
      end

      def pin
        254
      end

      def [](loc)
        if loc.class == Range
          index     = loc.first
          remaining = loc.count
          result    = []

          while remaining > 0
            size = (max_eeperom_txn < remaining) ? max_eeperom_txn : remaining
            end_address = index + size - 1
            raise ArgumentError, "EEPROM address #{end_address} out of range" if (end_address >= length)

            result    += read_using -> { board.eeprom_read(index, size) }
            index     += size
            remaining -= size
          end
          result
        else
          bytes = read_using -> { board.eeprom_read(loc, 1) }
          bytes[0]
        end
      end

      def []=(loc, value)
        if value.class == Array
          remaining = value.length
          src_start = 0
          dst_start = loc

          while remaining > 0
            size = (max_eeperom_txn < remaining) ? max_eeperom_txn : remaining
            src_end = src_start + size - 1
            raise ArgumentError, "EEPROM address #{src_end} out of range" if (src_end >= length)

            board.eeprom_write(dst_start, value[src_start..src_end])

            remaining -= size
            src_start += size
            dst_start += size
          end
        else
          board.eeprom_write(loc, [value])
        end
      end

      def pre_callback_filter(message)
        # address = message.split("-", 2)[0].to_i
        bytes = message.split("-", 2)[1].split(",").map(&:to_i)
      end
    end
  end
end
