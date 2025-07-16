module Denko
  module Behaviors
    module Component
      attr_reader :board, :params
      include State

      def initialize(options={})
        @params = options
        run_before_initialize_cbs

        initialize_board
        convert_pins
        initialize_pins
        register

        run_after_initialize_cbs
      end

      def micro_delay(duration)
        board.micro_delay(duration)
      end

      protected

      def initialize_board
        raise ArgumentError, 'a board is required for a component' unless params[:board]
        @board = params[:board]
      end

      def register
        board.add_component(self)
      end

      def unregister
        board.remove_component(self)
      end

      # Behaviors::Component only requires a board.
      # Include modules from Setup or override this to use pins.
      #
      def convert_pins;     end
      def initialize_pins;  end
      alias :initialize_pin :initialize_pins
    end
  end
end
