module Denko
  module Behaviors
    module State
      include Lifecycle

      # Force state and mutex initialization.
      after_initialize do
        @state_mutex = Denko.gil? ? Denko::MutexStub.new : Mutex.new
        state
      end

      # mruby optimization. Bypass state_mutex for simple states.
      if Denko.mruby?
        attr_accessor :state
      else
        def state
          @state_mutex.lock
          value = @state
          @state_mutex.unlock
          value
        end

        def state=(value)
          @state_mutex.lock
          @state = value
          @state_mutex.unlock
          @state
        end
      end

      def update_state(value)
        self.state = value if value
      end
    end
  end
end
