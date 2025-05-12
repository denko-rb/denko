module Denko
  module Display
    module SPIEPaperCommon
      include SPICommon

      def initialize_pins(options={})
        super(options)
        proxy_pin :busy, DigitalIO::Input, board: bus.board
        busy.stop
      end

      def busy_wait
        @busy_wait_time ||= self.class.const_get("BUSY_WAIT_TIME") if self.class.const_defined?("BUSY_WAIT_TIME")
        @busy_wait_time ||= 0.005

        # read more compatible than listener.
        sleep 0.005 while busy.read == 1
      end

      def hw_reset
        if reset
          @reset_time ||= self.class.const_get("RESET_TIME") if self.class.const_defined?("RESET_TIME")
          @reset_time ||= 0.1

          reset.low
          sleep @reset_time
          reset.high
        end
      end

      def draw(x_start=x_min, x_finish=x_max, y_start=y_min, y_finish=y_max)
        # Convert y-coords to page coords.
        p_start  = y_start  / 8
        p_finish = y_finish / 8

        # Send black framebuffer
        draw_partial(canvas.framebuffers[0], x_start, x_finish, p_start, p_finish, 1)

        # Send red framebuffer if enabled.
        draw_partial(canvas.framebuffers[1], x_start, x_finish, p_start, p_finish, 2) if (colors == 2)

        refresh
      end
    end
  end
end
