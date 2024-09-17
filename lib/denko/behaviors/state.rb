module Denko
  module Behaviors
    module State
      def initialize(options={})
        # Component includes State, so it calls super, not State.
        @state_mutex = Denko.cruby? ? Denko::MutexStub.new : Mutex.new
        @state = nil
      end
      
      def state
        @state_mutex.synchronize { @state }
      end
      
      protected

      def state=(value)
        @state_mutex.synchronize { @state = value }
      end
      
      def update_state(value)
        self.state = value if value
      end
    end
  end
end
