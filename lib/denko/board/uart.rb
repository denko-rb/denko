module Denko
  class Board
    UART_BAUDS = [
      300, 600, 750, 1200, 2400, 4800, 9600, 19200, 31250, 38400, 57600, 74880, 115200, 230400
    ]

    UART_CONFIGS = [ "8N1", "8E1", "8O1", "8N2", "8E2", "8O2" ]

    # CMD = 14
    def uart_start(index, baud=9600, config="8N1", listening=true)
      raise ArgumentError, "given UART: #{index} out of range. Only 1..3 supported" if (index < 1 || index > 3)
      unless UART_BAUDS.include?(baud)
        raise ArgumentError, "given baud rate: #{baud} not supported. Must be in #{UART_BAUDS.inspect}"
      end
      unless UART_CONFIGS.include?(config.upcase)
        raise ArgumentError, "given config: #{config} not supported. Must be in #{UART_CONFIGS.inspect}"
      end

      index |= 0b10000000  # enabled
      index |= 0b01000000 if listening
      config = UART_CONFIGS.find_index(config.upcase)

      self.write Message.encode command:     14,
                                pin:         index,
                                aux_message: pack(:uint32, baud) + pack(:uint8, config)
    end

    # CMD = 14
    def uart_stop(index)
      raise ArgumentError, "given UART: #{index} out of range. Only 1..3 supported" if (index < 1 || index > 3)
      self.write Message.encode(command: 14, pin: index)
    end

    # CMD = 15
    def uart_write(index, data)
      raise ArgumentError, "given UART: #{index} out of range. Only 1..3 supported" if (index < 1 || index > 3)

      if data.class == Array
        data = pack(:uint8, data)
      elsif data.class == String
      else
        raise ArgumentError, "data to write to UART should be Array of bytes or String. Given: #{data.inspect}"
      end

      self.write Message.encode(command: 15, pin: index, value: data.length, aux_message: data)
    end
  end
end
