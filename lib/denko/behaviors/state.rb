module Denko
  module Behaviors
    module State
      include Lifecycle

      # Force state initialization.
      after_initialize do
        state
      end

      def state_mutex
        @state_mutex ||= Denko.cruby? ? Denko::MutexStub.new : Mutex.new
        @state_mutex
      end

      def state
        state_mutex.synchronize { @state }
      end

      protected

      def state=(value)
        state_mutex.synchronize { @state = value }
      end

      def update_state(value)
        self.state = value if value
      end
    end
  end
end
