module Denko
  module LED
    class WS2812
      include Behaviors::SinglePin
      include Behaviors::Lifecycle

      def length
        @length ||= params[:length] || 1
      end

      def bpp
        @bpp ||= params[:bpp] || 3
      end

      attr_writer :length, :bpp

      after_initialize do
        off
      end

      def []=(index, array)
        # Just do GRB order for now.
        buffer[index*bpp]   = array[1]
        buffer[index*bpp+1] = array[0]
        buffer[index*bpp+2] = array[2]
      end

      def buffer
        @buffer ||= Array.new(length * bpp) { 0 }
      end

      def all_on
        buffer.map! { 255 } # should scale with brightness
        show
      end

      def off
        clear
        show
      end

      def clear
        buffer.map! { 0 }
      end

      def show
        board.show_ws2812(self.pin, self.buffer)
      end
    end
  end
end
