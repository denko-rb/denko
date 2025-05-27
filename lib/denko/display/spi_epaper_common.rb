module Denko
  module Display
    module SPIEPaperCommon
      include SPICommon

      # Defaults. Override in subclasses as needed.
      BUSY_WAIT_TIME = 0.005
      RESET_TIME     = 0.010

      def initialize_pins(options={})
        super(options)
        proxy_pin :busy, DigitalIO::Input, board: bus.board
        busy.stop
      end

      def busy_wait
        # #read is more compatible than #listen
        sleep self.class::BUSY_WAIT_TIME while busy.read == 1
      end

      def hw_reset
        if reset
          reset.low
          sleep self.class::RESET_TIME
          reset.high
        end
      end
    end
  end
end
