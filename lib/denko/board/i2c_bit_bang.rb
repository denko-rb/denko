module Denko
  class Board
    def i2c_bb_setup(scl, sda)
      # Stub method. Other implementations may call this.
    end

    # CMD = 30
    def i2c_bb_search(scl, sda)
      write Message.encode command: 30,
                           pin:     scl,
                           value:   sda
    end

    # CMD = 31
    def i2c_bb_write(scl, sda, address, bytes, repeated_start=false)
      bytes = [bytes] unless bytes.class == Array

      # Use top bit of address to select stop condition (1), or repated start (0).
      send_stop = repeated_start ? 0 : 1

      write Message.encode  command:     31,
                            pin:         scl,
                            value:       sda,
                            aux_message: pack(:uint8, 0x00) +
                                         pack(:uint8, address | (send_stop << 7)) +
                                         pack(:uint8, bytes.length) +
                                         pack(:uint8, bytes)
    end

    # CMD = 32
    def i2c_bb_read(scl, sda, address, register, read_length, repeated_start=false)
      # Use top bit of address to select stop condition (1), or repated start (0).
      send_stop = repeated_start ? 0 : 1

      # A register address starting register address can be given (up to 4 bytes)
      if register
        register = [register].flatten
        raise ArgumentError, 'maximum 4 byte register address for I2C read' if register.length > 4
        register_packed = pack(:uint8, [register.length] + register)
      else
        register_packed = pack(:uint8, [0])
      end

      write Message.encode  command:      32,
                            pin:          scl,
                            value:        sda,
                            aux_message:  pack(:uint8, 0x00) +
                                          pack(:uint8, address | (send_stop << 7)) +
                                          pack(:uint8, read_length) +
                                          register_packed
    end
  end
end
