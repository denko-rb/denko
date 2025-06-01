module Denko
  class Board
    # Use all of the board's aux buffer, except 8 bytes for header, or default to 512.
    # NOTE: SPI lengths are sent as 12-bit, so hard upper limit of 4095.
    def spi_limit
      @spi_limit ||= aux_limit ? aux_limit-8 : 512
    end

    def spi_header_generic(select_pin, write, read, mode=0, bit_order=:msbfirst)
      raise ArgumentError, "can't read more than #{spi_limit} SPI bytes at a time" if read > spi_limit
      raise ArgumentError, "can't write more than #{spi_limit} SPI bytes at a time" if write.length > spi_limit

      # Lowest 2 bits of settings hold the SPI mode number.
      raise ArgumentError, "invalid SPI mode: #{mode}. Must be 0, 1, 2, or 3" unless (0..3).include? mode
      settings = mode

      # Bit 7 of settings toggles MSBFIRST (1) or LSBFIRST (0) for both read and write.
      settings |= 0b10000000 unless bit_order == :lsbfirst

      # Bit 6 of settings indicates whether a select pin needs to be toggled.
      settings |= 0b01000000 if select_pin

      # 3 bytes are available for read and write length, so 12-bits each.
      # Bytes 1 and 2 are lower 8 bits for read and write respectively.
      # Byte 3 is shared: upper 4 hold read[8..12], lower 4 hold write.length[8..12]
      shared_byte = ((read & 0xF00) >> 4) | ((write.length & 0xF00) >> 8)

      # Generic portion (first 4 bytes), used by both hardware and bit bang SPI.
      pack :uint8, [settings, read & 0xFF, write.length & 0xFF, shared_byte]
    end

    def spi_header(select_pin, write, read, frequency=1_000_000, mode=0, bit_order=:msbfirst)
      raise ArgumentError, "error in SPI frequency: #{frequency}" unless [Integer, Float].include?(frequency.class)
      frequency = frequency.to_i

      # Generic header + packed frequency = hardware SPI header.
      header  = spi_header_generic(select_pin, write, read, mode, bit_order)
      header += pack(:uint32, frequency)
    end

    # CMD = 26
    def spi_transfer(spi_index, select_pin, write: [], read: 0, frequency: 1_000_000, mode: 0, bit_order: :msbfirst)
      raise ArgumentError, "no bytes given to read or write" if (read <= 0) && (write.empty?)
      raise ArgumentError, "select_pin cannot be nil when reading or listening" if (read > 0) && (select_pin == nil)

      header = spi_header(select_pin, write, read, frequency, mode, bit_order)

      self.write Message.encode command: 26,
                                pin: select_pin,
                                aux_message: header + pack(:uint8, write)
    end

    # CMD = 27
    def spi_listen(spi_index, select_pin, read: 0, frequency: 1_000_000, mode: 0, bit_order: :msbfirst)
      raise ArgumentError, 'no bytes to read. Give read: argument > 0' unless (read.class == Integer) && (read > 0)
      raise ArgumentError, "select_pin cannot be nil when reading or listening" if (select_pin == nil)

      header = spi_header(select_pin, [], read, frequency, mode, bit_order)

      self.write Message.encode command: 27,
                                pin: select_pin,
                                aux_message: header
    end

    # CMD = 28
    def spi_stop(select_pin)
      self.write Message.encode command: 28, pin: select_pin
    end
  end
end
