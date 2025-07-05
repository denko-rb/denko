module Denko
  module LED
    module TM163x
      include Behaviors::MultiPin

      # Always write all bytes, auto incrementing, starting at address 0.
      SET_DATA    = 0b01 << 6
      SET_ADDRESS = 0b11 << 6

      DISPLAY_CONTROL = 0b10 << 6
      ON_BIT = 0b1 << 3
      BRIGHTNESSES = {
        1   => 0b000,
        2   => 0b001,
        4   => 0b010,
        10  => 0b011,
        11  => 0b100,
        12  => 0b101,
        13  => 0b110,
        14  => 0b111
      }

      def display_control_register
        @display_control_register ||= DISPLAY_CONTROL
      end
      attr_writer :display_control_register

      def on
        self.display_control_register |= ON_BIT
        write_raw [display_control_register]
      end

      def off
        self.display_control_register &= ~ON_BIT
        write_raw [display_control_register]
      end

      def brightness=(key)
        unless BRIGHTNESSES.keys.include?(key)
          raise ArgumentError, "invalid brightness: #{key}. Must be one of: #{BRIGHTNESSES.keys.inspect}"
        end
        self.display_control_register &= ~(0b111)
        self.display_control_register |= BRIGHTNESSES[key]
        write_raw [display_control_register]
      end

      def write
        write_raw [SET_DATA]
        write_raw [SET_ADDRESS] + state
        write_raw [display_control_register]
      end

      def write_raw(bytes)
        raise NotImplementedError, "#write_raw not implemented for TM163x subclass"
      end
    end
  end
end
