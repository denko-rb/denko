module Denko
  module Behaviors
    module Listener
      include Callbacks

      attr_reader :divider

      #
      # These delegate to #_listen and #_stop_listener,
      # which should be defined in the including class.
      #
      def listen(divider=nil, &block)
        @divider = divider
        stop
        add_callback(:listen, &block) if block_given?
        _listen(@divider)
        @listening = true
      end

      def stop
        super if defined?(super)
        _stop_listener
        remove_callbacks :listen
        @listening = false
      end
    end
  end
end
