module Denko
  class Board
    DIVIDERS = [1, 2, 4, 8, 16, 32, 64, 128]

    PIN_MODES = {
                  output:             0b0000,
                  output_pwm:         0b0010,
                  output_dac:         0b0100,
                  output_open_drain:  0b0110,
                  output_open_source: 0b1000,
                  input:              0b0001,
                  input_pulldown:     0b0011,
                  input_pullup:       0b0101,
    }

    # CMD = 0
    def set_pin_mode(pin, mode=:input, options={})
      unless PIN_MODES.keys.include? mode
        raise ArgumentError, "cannot set mode: #{mode}. Should be one of: #{PIN_MODES.keys.inspect}"
      end

      # Set frequency and resolution for PWM if given.
      aux = nil
      if (mode == :output_pwm) && options
        aux    = [0, 0]
        aux[0] = options[:frequency] if options[:frequency]
        aux[1] = options[:resolution] if options[:resolution]
        aux = pack :uint32, aux, min: 8, max: 8
      end

      write Message.encode  command: 0,
                            pin: pin,
                            value: PIN_MODES[mode],
                            aux_message: aux
    end

    def set_pin_debounce(pin, debounce_time)
    end

    # CMD = 1
    def digital_write(pin,value)
      unless (value == 1) || (value == 0)
        raise ArgumentError, "cannot write digital value: #{value}. Should be Integer either 0 or 1"
      end
      write Message.encode command: 1, pin: pin, value: value
    end

    # CMD = 2
    def digital_read(pin)
      write Message.encode command: 2, pin: pin
    end

    # CMD = 3
    def pwm_write(pin,value)
      raise ArgumentError, "PWM value cannot be negative" if (value < 0)
      write Message.encode command: 3, pin: pin, value: value.round
    end

    # CMD = 4
    def dac_write(pin,value)
      if (value < 0) || (value > dac_high)
        raise ArgumentError, "cannot write DAC value: #{value}. Should be Integer in range 0..#{dac_high} "
      end
      write Message.encode command: 4, pin: pin, value: value.round
    end

    # CMD = 5
    def analog_read(pin, negative_pin=nil, gain=nil, sample_rate=nil)
      write Message.encode command: 5, pin: pin
    end

    # CMD = 6
    def set_listener(pin, state=:off, **options)
      # Default to digital listener and validate.
      options[:mode] ||= :digital
      unless (options[:mode] == :digital) || (options[:mode] == :analog)
        raise ArgumentError, "error in mode: #{options[:mode]}. Should be one of: [:digital, :analog]"
      end
      mode_byte = (options[:mode] == :digital) ? 0 : 1

      # Default to 4ms divider if digital, 16ms if analog.
      if options[:mode] == :digital
        options[:divider] ||= 4
      else
        options[:divider] ||= 16
      end

      # Convert divider to exponent and validate.
      exponent = Math.log2(options[:divider]).round
      if (exponent < 0) || (exponent > 7)
        raise ArgumentError, "error in divider: #{options[:divider]}. Should be one of: #{DIVIDERS.inspect}"
      end

      # Validate state.
      unless (state == :on) || (state == :off)
        raise ArgumentError, "error in state: #{options[:state]}. Should be one of: [:on, :off]"
      end
      state_byte = (state == :on) ? 1 : 0

      # Send it.
      write Message.encode  command: 6,
                            pin: pin,
                            value: state_byte,
                            aux_message: pack(:uint8, [mode_byte, exponent])
    end

    # Convenience methods that wrap set_listener.
    def digital_listen(pin, divider=4)
      set_listener(pin, :on, mode: :digital, divider: divider)
    end

    def analog_listen(pin, divider=16)
      set_listener(pin, :on, mode: :analog, divider: divider)
    end

    def stop_listener(pin)
      set_listener(pin, :off)
    end

    # CMD = 92
    #
    # For diagnostics and testing mostly. What this does:
    # 1) Tell the Connection to halt transmission immediately, after this message.
    # 2) The board will send back a ready signal, which the Connection should read and resume transmisison.
    #
    # See comments on Board#write_and_halt for more info and use case.
    #
    def halt_resume_check
      write_and_halt Message.encode command: 92
    end

    # CMD = 95
    def set_register_divider(value)
      unless DIVIDERS.include?(value)
        raise ArgumentError, "error in divider: #{value}. Should be one of: #{DIVIDERS.inspect}"
      end
      write Message.encode(command: 95, value: value)
    end

    # CMD = 96
    def set_analog_write_resolution(value)
      if (value < 0) || (value > 16)
        raise ArgumentError, "cannot set resolution: #{value}. Should be Integer in range 0..16"
      end
      write Message.encode(command: 96, value: value)
    end

    # CMD = 97
    def set_analog_read_resolution(value)
      if (value < 0) || (value > 16)
        raise ArgumentError, "cannot set resolution: #{value}. Should be Integer in range 0..16"
      end
      write Message.encode(command: 97, value: value)
    end

    # CMD = 98
    def binary_echo(pin, data=[])
      write Message.encode command: 98, pin: pin, value: data.length, aux_message: pack(:uint8, data)
    end

    # CMD = 99
    def micro_delay(duration)
      if (duration < 0) || (duration > 0xFFFF)
        raise ArgumentError, "error in duration: #{duration}. Should be Integer in range 0..65535"
      end
      write Message.encode command: 99, aux_message: pack(:uint16, [duration])
    end
  end
end
