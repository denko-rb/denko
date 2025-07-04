module Denko
  class Board
    # CMD = 9
    def pulse_read(pin, reset: false, reset_time: 0, pulse_limit: 100, timeout: 200)
      # Validation
      raise ArgumentError, "error in reset: #{reset}. Should be either #{high} or #{low}"         if reset && ![high, low].include?(reset)
      raise ArgumentError, "errror in reset_time: #{reset_time}. Should be 0..65535 microseconds" if (reset_time < 0) || (reset_time > 0xFFFF)
      raise ArgumentError, "errror in pulse_limit: #{pulse_limit}. Should be 0..255 pulses"       if (pulse_limit < 0) || (pulse_limit > 0xFF)
      raise ArgumentError, "errror in timeout: #{timeout}. Should be 0..65535 milliseconds"       if (timeout < 0) || (timeout > 0xFFFF)

      # Bit 0 of settings mask controls whether to hold high/low for reset.
      settings = reset ? 1 : 0

      # Bit 1 of settings mask controls whether to hold high (1) or to hold low (0).
      settings = settings | 0b10 if (reset && reset != low)

      # Pack and send.
      aux = pack :uint16, [reset_time, timeout]
      aux << pack(:uint8, pulse_limit)
      write Message.encode  command: 9,
                            pin: pin,
                            value: settings,
                            aux_message: aux
    end

    def hcsr04_read(echo_pin, trigger_pin)
      write Message.encode(command: 20, pin: echo_pin, value: trigger_pin)
    end

    def shift_out_nine(clk, dio, bytes)
      prepack = bytes.flatten
      raise ArgumentError, "data must be 1..255 bytes long" if (prepack.length > 255 || prepack.length < 1)
      prepack.unshift(prepack.length)

      write Message.encode command: 39, pin: clk, value: dio, aux_message: pack(:uint8, prepack)
    end
  end
end
