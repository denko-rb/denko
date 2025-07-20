module Denko
  module AnalogIO
    class Output
      include Behaviors::OutputPin
      include Behaviors::Callbacks
      include Behaviors::Threaded
      include Behaviors::Lifecycle

      interrupt_with :write

      before_initialize do
        params[:mode] = :output_dac
      end

      def write(value)
        @board.dac_write(@pin, value)
        @state = value
      end
    end
  end
end
