module Denko
  module Sensor
    #
    # For JSN-SR04T sensor in mode 2 ONLY.
    #
    class JSNSR04T
      include Behaviors::Component
      include Behaviors::Lifecycle
      include Behaviors::Poller

      UART_CLASSES = [Denko::UART::Hardware, Denko::UART::BitBang]
      TIMEOUT      = 0.500

      attr_reader :uart

      after_initialize do
        unless params[:uart] && UART_CLASSES.include?(params[:uart].class)
          raise ArgumentError, "JSN-SR04T driver only works in mode 2, and expects a UART in the :uart key"
        end

        raise StandardError, "UART baud must be 9600 for JSN-SR04T" unless params[:uart].baud == 9600

        @uart = params[:uart]
      end

      def _read
        # Trigger read
        uart.write("U")

        # Get line from UART
        start = Time.now
        line  = nil
        until line || (Time.now - start > TIMEOUT)
          line = uart.gets
          sleep 0.010
        end

        # Extract mm as integer
        if line && line.strip.end_with?("mm")
          value = line.gsub("mm").strip.to_i
          self.update(value)
          return value
        end

        return nil
      end
    end
  end
end
