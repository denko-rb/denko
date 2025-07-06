module Denko
  module LED
    class SevenSegmentSPI < SPI::OutputRegister
      # Model 1+ SevenSegment, through 1+ series shift registers, like 4HC595.
      include SevenSegmentArray

      before_initialize do
        params[:bytes]    ||= params[:digits]
        params[:inverted] ||= params[:invert]
      end

      after_initialize do
        initialize_segments
      end

      def initialize_segments
        @digits = []
        digit_count.times do |index|
          # Starting bit offset for each digit, treating it as one multi-byte register.
          i = index*8

          if rotated
            # Swap segments to rotate individual digits, and ignore decimal points when rotated.
            pins = { a: i+3, b: i+4, c: i+5, d: i+0, e: i+1, f: i+2, g: i+6 }
            # Add digits in forward order, since !rotated needs them reversed.
            digits[index] = SevenSegment.new(board: self, pins: pins, inverted: params[:inverted])
          else
            pins = { a: i+0, b: i+1, c: i+2, d: i+3, e: i+4, f: i+5, g: i+6, dp: i+7 }
            # Last register in series chain gets first byte, so reverse the order.
            digits[(digit_count-1) - index] = SevenSegment.new(board: self, pins: pins, inverted: params[:inverted])
          end
        end
      end
    end
  end
end
