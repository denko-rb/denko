module Denko
  module LED
    class TM1637
      include Behaviors::MultiPin
      include Behaviors::Lifecycle

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

      def board_platform
        @board_platform ||= board.platform
      end

      def initialize_pins(options={})
        proxy_pin :clk, DigitalIO::Output
        proxy_pin :dio, DigitalIO::Output
      end

      after_initialize do
        # Bus idle condition
        clk.high
        dio.high

        state
        off
        initialize_segments
        self.brightness = 10
        on
      end

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

      #
      # LED array interface
      #
      attr_reader :digits, :colon

      def digit_count
        4
      end

      def initialize_segments
        @digits = []

        digit_count.times do |index|
          # Starting bit offset for each digit, treating TM1637 as a 32-bit register.
          i = index*8

          if params[:rotate]
            # Swap segments to rotate individual digits, and add them in reverse order.
            digit = SevenSegment.new board: self,
                                     pins: { a: i+3, b: i+4, c: i+5, d: i+0, e: i+1, f: i+2, g: i+6 }
            digits[(digit_count-1) - index] = digit
          else
            digit = SevenSegment.new board: self,
                                     pins: { a: i+0, b: i+1, c: i+2, d: i+3, e: i+4, f: i+5, g: i+6 }
            digits[index] = digit
          end
        end

        @colon = DigitalIO::Output.new board: self, pin: 15
      end

      def text(str)
        digit_count.times { |i| digits[i].write(str[i], soft: true) }
        write
      end

      #
      # BoardProxy interface
      #
      include Denko::Behaviors::BoardProxy

      def state
        @state ||= Array.new(4) { 0 }
      end

      def digital_write(pin, value)
        bit_set(pin, value)
        write
      end

      def bit_set(pin, value)
        byte = pin / 8
        bit  = pin % 8

        @state_mutex.lock
          if value == 0
            @state[byte] &= ~(0b1 << bit)
          else
            @state[byte] |= (0b1 << bit)
          end
        @state_mutex.unlock

        value
      end

      def digital_read(pin)
        byte = pin / 8
        bit  = pin % 8

        (state[byte] >> bit) & 0b1
      end

      def pin_is_pwm?(pin)
        false
      end

      #
      # Low-level write methods
      #
      def write
        write_raw [SET_DATA]
        write_raw [SET_ADDRESS] + state
        write_raw [display_control_register]
      end

      # Connected Arduinos have a C implementation. Everything else bit-bangs in Ruby.
      def write_raw(bytes)
        (board_platform == :arduino) ? write_raw_c(bytes) : write_raw_ruby(bytes)
      end

      def write_raw_c(bytes)
        board.shift_out_nine(clk.pin, dio.pin, bytes)
      end

      # This is like a modified version of bit-bang I2C. No address and LSBFIRST.
      #
      # Max speed is 250kHz according to datasheet. Doing it in Ruby, and calling
      # pin methods (rather than board), should be slow enough to not need delays.
      #
      def write_raw_ruby(bytes)
        # Start condition
        dio.low
        clk.low

        bytes.each do |byte|
          # Empty 9th bit imitates/ignores (N)ACK
          (0..8).each do |index|
            bit = (byte >> index) & 0b1
            (bit == 0) ? dio.low : dio.high
            clk.high
            clk.low
          end
        end

        # Stop condition
        dio.low
        clk.high
        dio.high
      end
    end
  end
end
