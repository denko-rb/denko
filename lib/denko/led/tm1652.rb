module Denko
  module LED
    class TM1652
      include Behaviors::Component
      include SevenSegmentArray
      include Behaviors::Lifecycle

      PREFIX_CONTROL  = 0b00011000
      PREFIX_ADDRESS  = 0b00001000
      DISPLAY_CONTROL = 0b00000000
      DUTY_RATIOS = {
        0  => 0b0000,
        1  => 0b1000,
        2  => 0b0100,
        3  => 0b1100,
        4  => 0b0010,
        5  => 0b1010,
        6  => 0b0110,
        7  => 0b1110,
        8  => 0b0001,
        9  => 0b1001,
        10 => 0b0101,
        11 => 0b1101,
        12 => 0b0011,
        13 => 0b1011,
        14 => 0b0111,
        15 => 0b1111
      }
      DRIVE_CURRENTS = {
        1  => 0b000,
        2  => 0b100,
        3  => 0b010,
        4  => 0b110,
        5  => 0b001,
        6  => 0b101,
        7  => 0b011,
        8  => 0b111,
      }

      BYTE_COUNT  = 4
      DIGIT_COUNT = 4

      attr_reader :uart

      after_initialize do
        unless params[:uart].is_a?(Denko::UART::Hardware)
          raise ArgumentError, "TM1652 requires a hardware UART in the :uart key"
        end

        raise StandardError, "UART baud must be 19200 for TM1652" unless params[:uart].baud == 19200

        @uart = params[:uart]

        state
        self.duty_ratio = 15
        self.drive_current = 8
        initialize_segments
      end

      def initialize_segments
        @digits = []
        DIGIT_COUNT.times do |index|
          # Starting bit offset for each digit, treating TM1652 as a 32-bit register.
          i = index*8

          if rotated
            # Swap segments to rotate individual digits, and ignore decimal points when rotated.
            pins = { a: i+3, b: i+4, c: i+5, d: i+0, e: i+1, f: i+2, g: i+6 }
            pins[:colon] = i+7 if (index == 1)
            # Add digits in reverse order to finish rotation.
            digits[(DIGIT_COUNT-1) - index] = SevenSegment.new(board: self, pins: pins)
          else
            pins = { a: i+0, b: i+1, c: i+2, d: i+3, e: i+4, f: i+5, g: i+6, dp: i+7 }
            if (index == 1)
              pins.delete(:dp)
              pins[:colon] = i+7
            end
            digits[index] = SevenSegment.new(board: self, pins: pins)
          end
        end

        @colon = rotated ? digits[2].proxies[:colon] : digits[1].proxies[:colon]
      end

      def display_control_register
        @display_control_register ||= DISPLAY_CONTROL
      end
      attr_writer :display_control_register

      def duty_ratio=(value)
        unless DUTY_RATIOS.keys.include?(value)
          raise ArgumentError, "invalid duty_ratio: #{value}. Should be in #{DUTY_RATIOS.keys.inspect}"
        end
        @duty_ratio = value

        self.display_control_register &= ~0b11110000
        self.display_control_register |= (DUTY_RATIOS[@duty_ratio] << 4)

        write_control [display_control_register]
      end
      attr_reader :duty_ratio

      def off
        # Write 0000 to high nibble of display control register, but don't change @duty_ratio.
        self.display_control_register &= ~0b11110000
        write_control [display_control_register]
      end

      def on
        # Write @duty_ratio back to display_control_register.
        self.duty_ratio = duty_ratio
      end

      def drive_current=(value)
        unless DRIVE_CURRENTS.keys.include?(value)
          raise ArgumentError, "invalid drive_current: #{value}. Should be in #{DRIVE_CURRENTS.keys.inspect}"
        end
        @drive_current = value

        self.display_control_register &= ~0b00001110
        self.display_control_register |= (DUTY_RATIOS[@drive_current] << 1)

        write_control [display_control_register]
      end
      attr_reader :drive_current

      def write(data=state)
        write_data(data)
        write_control [display_control_register]
      end

      def write_control(byte)
        bytes = [PREFIX_CONTROL, byte].flatten
        uart.write(bytes)
        board.micro_delay(3000)
      end

      def write_data(data)
        bytes = [PREFIX_ADDRESS, data].flatten
        uart.write(bytes)
        board.micro_delay(3000)
      end
    end
  end
end
