module Denko
  class Board
    def infrared_emit(pin, frequency, pulses)
      #
      # Limit to 255 marks/spaces (not pairs).
      #
      # Make length uint16 as well, for aligned memory access on ESP8266.
      # Pulses max is 2x255 bytes long since each is 2 bytes.
      length = pack :uint16, pulses.length,  max: 2
      bytes  = pack :uint16, pulses, min: 1, max: 510

      write Message.encode command: 16,
                          pin: pin,
                          value: frequency,
                          aux_message: length + bytes
    end
  end
end
