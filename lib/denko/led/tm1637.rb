module Denko
  module LED
    class TM1637
      include TM163x
      include Behaviors::Lifecycle

      BYTE_COUNT  = 4
      DIGIT_COUNT = 4

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

      def initialize_segments
        @digits = []
        DIGIT_COUNT.times do |index|
          # Starting bit offset for each digit, treating TM1652 as a 32-bit register.
          i = index*8

          if rotated
            # Swap segments to rotate individual digits.
            pins = { a: i+3, b: i+4, c: i+5, d: i+0, e: i+1, f: i+2, g: i+6 }
            pins[:colon] = i+7 if (index == 1)
            # Add digits in reverse order to finish rotation.
            digits[(DIGIT_COUNT-1) - index] = SevenSegment.new(board: self, pins: pins)
          else
            pins = { a: i+0, b: i+1, c: i+2, d: i+3, e: i+4, f: i+5, g: i+6 }
            pins[:colon] = i+7 if (index == 1)
            digits[index] = SevenSegment.new(board: self, pins: pins)
          end
        end

        @colon = rotated ? digits[2].proxies[:colon] : digits[1].proxies[:colon]
      end

      #
      # Low-level write methods
      #
      # Connected Arduinos have a C implementation. Everything else bit-bangs in Ruby.
      def write_raw(bytes)
        (board_platform == :arduino) ? write_raw_c(bytes) : write_raw_ruby(bytes)
      end

      def board_platform
        @board_platform ||= board.platform
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
