module Denko
  module Behaviors
    module Poller
      include Reader
      include Threaded

      def poll_using(reader_method, interval, &block)
        mruby_thread_check

        unless [Integer, Float].include? interval.class
          raise ArgumentError, "wrong interval given to #poll : #{interval.inspect}"
        end

        stop

        add_callback(:poll, &block) if block_given?

        threaded_loop do
          sleep READ_WAIT_TIME while (@read_type != :idle)
          @read_type = :regular
          reader_method.call
          sleep interval
        end
      end

      def poll(interval, &block)
        poll_using(self.method(:_read), interval, &block)
      end

      def stop
        begin; super; rescue NoMethodError; end
        remove_callbacks :poll
      end
    end
  end
end
