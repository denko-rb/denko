module Denko
  class Board
    def spi_bb_header(clock, input, output, select_pin, write, read, mode=0, bit_order=:msbfirst)
      raise ArgumentError, "either output or input pin required" unless (input || output)
      raise ArgumentError, "clock pin required" unless clock

      # Set the other to disabled if only one given.
      input  ||= 255
      output ||= 255

      # Generic header + packed pins + empty byte = bit bang SPI header.
      header = spi_header_generic(select_pin, write, read, mode, bit_order)
      header = header + pack(:uint8, [clock, input, output, 0])
    end

    # CMD = 21
    def spi_bb_transfer(select_pin, clock: nil, output: nil, input: nil, write: [], read: 0, frequency: nil, mode: 0, bit_order: :msbfirst)
      raise ArgumentError, "no bytes given to read or write" if (read <= 0) && (write.empty?)
      raise ArgumentError, "select_pin cannot be nil when reading or listening" if (read > 0) && (select_pin == nil)

      header = spi_bb_header(clock, input, output, select_pin, write, read, mode, bit_order)

      self.write Message.encode command: 21,
                                pin: select_pin,
                                aux_message: header + pack(:uint8, write)
    end

    # CMD = 22
    def spi_bb_listen(select_pin, clock: nil, input: nil, read: 0, frequency: nil, mode: 0, bit_order: :msbfirst)
      raise ArgumentError, 'no bytes to read. Give read: argument > 0' unless (read.class == Integer) && (read > 0)
      raise ArgumentError, "select_pin cannot be nil when reading or listening" if (select_pin == nil)

      header = spi_bb_header(clock, input, nil, select_pin, [], read, mode, bit_order)

      self.write Message.encode command: 22,
                                pin: select_pin,
                                aux_message: header
    end
  end
end
