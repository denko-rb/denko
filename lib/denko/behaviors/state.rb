module Denko
  module Behaviors
    module State
      include Lifecycle

      # Force state and mutex initialization.
      after_initialize do
        @state_mutex = Denko.cruby? ? Denko::MutexStub.new : Mutex.new
        state
      end

      def state
        @state_mutex.lock
        value = @state
        @state_mutex.unlock
        value
      end

      protected

      def state=(value)
        @state_mutex.lock
        @state = value
        @state_mutex.unlock
        @state
      end

      def update_state(value)
        self.state = value if value
      end
    end
  end
end
