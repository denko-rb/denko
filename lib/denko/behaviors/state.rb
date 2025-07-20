module Denko
  module Behaviors
    module State
      include Lifecycle

      attr_accessor :state

      # Ok for single values. If @state is Array, Hash etc. it is best to redefine
      # this so values are updated without reallocating memory, for mruby performance.
      def update_state(value)
        @state = value
      end
    end
  end
end
