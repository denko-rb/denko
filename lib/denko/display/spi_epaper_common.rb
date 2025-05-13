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
          @reset_time ||= 0.010

          reset.low
          sleep @reset_time
          reset.high
        end
      end
    end
  end
end
