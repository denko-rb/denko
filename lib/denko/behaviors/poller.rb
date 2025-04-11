module Denko
  module Behaviors
    module Poller
      include Reader
      include Threaded

      def poll_using(method, interval, *args, &block)
        unless [Integer, Float].include? interval.class
          raise ArgumentError, "wrong interval given to #poll : #{interval.inspect}"
        end

        stop
        add_callback(:poll, &block) if block_given?

        threaded_loop do
          # Lock, THEN wait for other normal reads to finish.
          @reader_mutex.lock
          sleep 0.001 while read_busy?
          @reading_normally = true

          method.call(*args)
          @reader_mutex.unlock

          sleep interval
        end
      end

      def poll(interval, *args, &block)
        poll_using(self.method(:_read), interval, *args, &block)
      end

      def stop
        super if defined?(super)
        remove_callbacks :poll
      end
    end
  end
end
