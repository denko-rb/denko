module Denko
  module Behaviors
    module Poller
      include Reader
      include Threaded

      def poll_using(method, interval, *args, **kwargs, &block)
        mruby_thread_check

        unless [Integer, Float].include? interval.class
          raise ArgumentError, "wrong interval given to #poll : #{interval.inspect}"
        end

        stop
        add_callback(:poll, &block) if block_given?

        threaded_loop do
          sleep READ_WAIT_TIME while (@read_type != :idle)

          @read_type = :regular
          method.call(*args, **kwargs)

          sleep interval
        end
      end

      def poll(interval, *args, **kwargs, &block)
        poll_using(self.method(:_read), interval, *args, **kwargs, &block)
      end

      def stop
        begin; super; rescue NoMethodError; end
        remove_callbacks :poll
      end
    end
  end
end
