module Denko
  module LED
    class SevenSegment
      include Behaviors::MultiPin
      
      ALL_OFF = [0,0,0,0,0,0,0]
      BLANK = " "

      def initialize_pins(options={})
        [:a, :b, :c, :d, :e, :f, :g].each do |symbol|
          proxy_pin(symbol, DigitalIO::Output)
        end

        proxy_pin :cathode, DigitalIO::Output, optional: true
        proxy_pin :anode,   DigitalIO::Output, optional: true
      end
      
      def after_initialize(options={})
        @segments = [a,b,c,d,e,f,g]
        clear; on
      end

      attr_reader :segments

      def clear
        write(BLANK)
      end

      def display(string)
        on unless on?
        string = string.to_s.upcase
        (string.length > 1) ? scroll(string) : write(string)
      end

      def on
        anode.high if anode
        cathode.low if cathode
        @on = true
      end

      def off
        anode.low if anode
        cathode.high if cathode
        @on = false
      end

      def on?;   @on; end
      def off?; !@on; end
      
      CHARACTERS = {
        '0' => [1,1,1,1,1,1,0],
        '1' => [0,1,1,0,0,0,0],
        '2' => [1,1,0,1,1,0,1],
        '3' => [1,1,1,1,0,0,1],
        '4' => [0,1,1,0,0,1,1],
        '5' => [1,0,1,1,0,1,1],
        '6' => [1,0,1,1,1,1,1],
        '7' => [1,1,1,0,0,0,0],
        '8' => [1,1,1,1,1,1,1],
        '9' => [1,1,1,1,0,1,1],
        ' ' => [0,0,0,0,0,0,0],
        '_' => [0,0,0,1,0,0,0],
        '-' => [0,0,0,0,0,0,1],
        'A' => [1,1,1,0,1,1,1],
        'B' => [0,0,1,1,1,1,1],
        'C' => [0,0,0,1,1,0,1],
        'D' => [0,1,1,1,1,0,1],
        'E' => [1,0,0,1,1,1,1],
        'F' => [1,0,0,0,1,1,1],
        'G' => [1,0,1,1,1,1,0],
        'H' => [0,0,1,0,1,1,1],
        'I' => [0,0,1,0,0,0,0],
        'J' => [0,1,1,1,1,0,0],
        'K' => [1,0,1,0,1,1,1],
        'L' => [0,0,0,1,1,1,0],
        'M' => [1,1,1,0,1,1,0],
        'N' => [0,0,1,0,1,0,1],
        'O' => [0,0,1,1,1,0,1],
        'P' => [1,1,0,0,1,1,1],
        'Q' => [1,1,1,0,0,1,1],
        'R' => [0,0,0,0,1,0,1],
        'S' => [1,0,1,1,0,1,1],
        'T' => [0,0,0,1,1,1,1],
        'U' => [0,0,1,1,1,0,0],
        'V' => [0,1,1,1,1,1,0],
        'W' => [0,1,1,1,1,1,1],
        'X' => [0,1,1,0,1,1,1],
        'Y' => [0,1,1,1,0,1,1],
        'Z' => [1,1,0,1,1,0,0],
      }

      private

      def write(char)
        bits = CHARACTERS[char] || ALL_OFF
        bits.each_with_index do |bit, index|
          bit = 1^bit if anode
          segments[index].write(bit) unless (segments[index].state == bit)
        end
      end

      def scroll(string)
        string.chars.each do |char|
          write(char)
          sleep(0.5)
        end
      end
    end
  end
end
