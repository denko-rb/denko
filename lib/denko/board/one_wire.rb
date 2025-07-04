module Denko
  class Board
    def one_wire_reset(pin, read_presence=false)
      write Message.encode  command: 41,
                            pin: pin,
                            value: read_presence ? 1 : 0
    end

    def one_wire_search(pin, branch_mask)
      write Message.encode  command: 42,
                            pin: pin,
                            aux_message: pack(:uint64, branch_mask, max: 8)
    end

    def one_wire_write(pin, parasite_power, data)
      bytes  = pack :uint8, data, min: 1, max: 127 # Should be 128 with 0 = 1.

      # Set high bit of length if the bus must drive high after write.
      length = bytes.length
      length = length | 0b10000000 if parasite_power

      write Message.encode  command: 43,
                            pin: pin,
                            value: length,
                            aux_message: bytes
    end

    def one_wire_read(pin, num_bytes)
      write Message.encode  command: 44,
                            pin: pin,
                            value: num_bytes
    end
  end
end
