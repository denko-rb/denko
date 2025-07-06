module Denko
  module LED
    class SevenSegment
      include Behaviors::MultiPin
      include Behaviors::Lifecycle

      ALL_OFF = [0,0,0,0,0,0,0]
      BLANK = " "

      def initialize_pins(options={})
        [:a, :b, :c, :d, :e, :f, :g].each do |symbol|
          proxy_pin(symbol, DigitalIO::Output)
        end

        if params[:pins][:dp] && params[:pins][:colon]
          raise ArgumentError "SevenSegment can have decimal point or colon, but not both"
        end
        proxy_pin :dp,      DigitalIO::Output, optional: true
        proxy_pin :colon,   DigitalIO::Output, optional: true

        if params[:pins][:cathode] && params[:pins][:anode]
          raise ArgumentError "SevenSegment can have cathode or anode, but not both"
        end
        proxy_pin :cathode, DigitalIO::Output, optional: true
        proxy_pin :anode,   DigitalIO::Output, optional: true

        invert if anode
        invert if (params[:inverted] || params[:invert])
      end

      attr_accessor :inverted

      def invert
        self.inverted = !inverted
      end

      def segments
        @segments ||= [a,b,c,d,e,f,g]
      end

      after_initialize do
        clear
        on
      end

      def clear
        write(BLANK)
      end

      def display(string)
        str = string.to_s

        if (str.length == 1)
          write(str)
        else
          # If 2 chars long, where second is dp or colon, and it exists.
          if (str.length == 2) && ((dp && str[1] == ".") || (colon && str[1] == ":"))
            write(str)
          else
            scroll(str)
          end
        end

        on unless on?
      end

      def on
        anode.high  if anode
        cathode.low if cathode
        @on = true
      end

      def off
        anode.low    if anode
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

      def write(string, soft: false)
        str     = string.to_s.upcase
        char    =  str[0]
        bits    = CHARACTERS[char] || ALL_OFF
        bits    = bits.map { |b| 1^b } if inverted

        dp_bit  = (str[1] == ".") ? 1 : 0
        dp_bit  = 1^dp_bit if inverted
        col_bit = (str[1] == ":") ? 1 : 0
        col_bit = 1^col_bit if inverted

        if board.is_a?(Denko::Behaviors::BoardProxy)
          # On BoardProxy, use #bit_set on all but the last bit, or all if :soft writing.
          # Calling #digital_write for last bit tells the proxy to flush registers to its parallel outpus.
          board.bit_set(dp.pin, dp_bit) if dp
          board.bit_set(colon.pin, col_bit) if colon

          bits.each_with_index do |bit, index|
            if (index == bits.length-1) && (!soft)
              segments[index].digital_write(bit)
            else
              board.bit_set(segments[index].pin, bit)
            end
          end
        else
          # On Board, only write changed bits.
          dp.digital_write(dp_bit) if (dp && dp.state != dp_bit)
          colon.digital_write(col_bit) if (colon && colon.state != col_bit)

          bits.each_with_index do |bit, index|
            segments[index].digital_write(bit) unless (segments[index].state == bit)
          end
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
