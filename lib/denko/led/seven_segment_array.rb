module Denko
  module LED
    module SevenSegmentArray
      include Behaviors::OutputRegister
      include Behaviors::Lifecycle

      DIGIT_COUNT = 1

      def digit_count
        @digit_count = params[:digits] || self.class::DIGIT_COUNT
      end
      attr_reader :digits, :colon

      after_initialize do
        @rotated = params[:rotated] || params[:rotate]
      end
      attr_reader :rotated

      PUNCTUATION = [".", ":"]

      def text(str)
        # Split into either single chars, or pair of char + displayable punctuation mark.
        chars = []
        index = 0
        while chars.length < digits.count
          char = str[index]
          index += 1
          if PUNCTUATION.include? str[index]
            char << str[index]
            index += 1
          end
          chars << char
        end

        # Move colon to next digit, so it shows when rotated. Ignore decimal points.
        if rotated
          chars.reverse!
          chars.each_with_index do |char, i|
            if (char[1] == ":") && (i > 0)
              chars[i] = char[0]
              chars[i-1][1] = ":"
            end
          end
          chars.reverse!
        end

        digits.each_with_index { |d, i| d.write(chars[i], soft: true) }
        write
      end
    end
  end
end
