module Denko
  module LED
    class TM1638
      include TM163x
      include SevenSegmentArray
      include Behaviors::Lifecycle

      BYTE_COUNT  = 16
      DIGIT_COUNT = 8
      LED_COUNT   = 8

      def initialize_pins(options={})
        proxy_pin :clk, DigitalIO::CBitBang
        proxy_pin :dio, DigitalIO::CBitBang
        proxy_pin :stb, DigitalIO::Output
      end

      after_initialize do
        # Essentially a SPI select pin, so idle high.
        stb.high

        state
        off
        initialize_segments
        self.brightness = 10
        on
      end

      attr_reader :leds

      def initialize_segments
        @digits = []
        DIGIT_COUNT.times do |index|
          # Starting bit offset for each digit, treating TM1638 as a 128-bit register, with a digit on every even byte.
          i = index*8*2

          if params[:rotate]
            # Swap segments to rotate individual digits, and add them in reverse order.
            digit = SevenSegment.new board: self,
                                     pins: { a: i+3, b: i+4, c: i+5, d: i+0, e: i+1, f: i+2, g: i+6 }
            digits[(DIGIT_COUNT-1) - index] = digit
          else
            digit = SevenSegment.new board: self,
                                     pins: { a: i+0, b: i+1, c: i+2, d: i+3, e: i+4, f: i+5, g: i+6 }
            digits[index] = digit
          end
        end

        @leds = []
        LED_COUNT.times do |index|
          # Bit 0 of every odd byte is connected to a standalone LED.
          i = (index*8*2) + 8
          led = Denko::DigitalIO::Output.new board:self, pin: i
          leds[index] = led
        end
      end

      def write_raw(bytes)
        stb.low
        board.spi_bb_transfer(nil, clock: clk.pin, output: dio.pin, write: bytes, mode: 0, bit_order: :lsbfirst)
        stb.high
      end
    end
  end
end
