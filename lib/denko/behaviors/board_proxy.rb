module Denko
  module Behaviors
    #
    # Provides a **bare-minimum** interface matching {Board}, so peripheral instances may
    # transparently use a `BoardProxy` (eg. a shift register) in place of a `Board`.
    #
    # @example LED through a shift register
    #   # Board, SPI bus, and output shift register.
    #   board = Denko::Board.new(Denko::Connection::Serial.new)
    #   bus = Denko::SPI::BitBang.new(board: board, pins: { clock: 13, output: 11 })
    #   register = Denko::SPI::OutputRegister.new(bus: bus, pin: 10)
    #
    #   # LED connected to register's parallel output pin 2.
    #   led = Denko::LED.new(board: register, pin: 2)
    #
    #   # OutputRegister defines #digital_write, so this works.
    #   led.blink 0.5
    #   sleep
    #
    module BoardProxy
      include Subcomponents

      # @return [Symbol] platform identifier (default `:proxy`)
      def platform
        :proxy
      end

      # @return [Integer] always returns 1
      def high
        1
      end

      # @return [Integer] always returns 0
      def low
        0
      end

      # Should be implemented to return maximum ADC value (eg. 1023 for 10-bit resolution).
      #
      # @abstract
      # @return [Integer] maximum ADC value
      def analog_read_high
        raise NotImplementedError, "#analog_read_high not implemented for #{self.class}"
      end

      # Should be implemented to return maximum PWM or DAC value (eg. 255 for 8-bit resolution).
      #
      # @abstract
      # @return [Integer] maximum PWM or DAC value
      def analog_write_high
        raise NotImplementedError, "#analog_write_high not implemented for #{self.class}"
      end

      # @return [Integer] alias of {#analog_read_high}
      def adc_high
        analog_read_high
      end

      # @return [Integer] alias of {#analog_write_high}
      def pwm_high
        analog_write_high
      end

      # @return [Integer] alias of {#analog_write_high}
      def dac_high
        analog_write_high
      end

      # Converts a pin identifier to integer by calling `#to_i` on it by default.
      #
      # @param pin [Object] the pin identifier to convert
      # @return [Integer] the pin as an integer
      def convert_pin(pin)
        pin.to_i
      end

      # Stub method that may be overriden with custom behavior to set a pin's I/O mode.
      #
      # @abstract
      # @param pin [Integer] the pin to configure
      # @param mode [Symbol] the mode to set
      # @param options [Hash] additional options
      def set_pin_mode(pin, mode, options = {}); end

      # Should be implemented to set a bit (pin) in instance variable storage,
      # without writing to hardware.
      #
      # @abstract
      # @param pin [Integer] the pin to modify
      # @param value [Integer] the value to set
      def bit_set(pin, value)
        raise NotImplementedError, "#bit_set not implemented for #{self.class}"
      end
    end
  end
end
