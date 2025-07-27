module Denko
  module Behaviors
    module Register
      include BoardProxy
      include Lifecycle

      BYTE_COUNT = 1

      def bytes
        @bytes = params[:bytes] || self.class::BYTE_COUNT
      end

      after_initialize do
        old_state
        state
      end

      def old_state
        @old_state ||= Array.new(bytes) { 0 }
      end

      def state
        @state ||= Array.new(bytes) { 0 }
      end

      def pin_is_pwm?(pin)
        false
      end
    end
  end
end
