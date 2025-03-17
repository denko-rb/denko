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
        @divider = divider || @listener
        stop
        add_callback(:listen, &block) if block_given?
        _listen(@divider)
      end

      def stop
        super if defined?(super)
        _stop_listener
        remove_callbacks :listen
      end
    end
  end
end
