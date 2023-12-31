module Denko
  module Behaviors
    module Listener
      include Callbacks
      
      attr_reader :divider

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
