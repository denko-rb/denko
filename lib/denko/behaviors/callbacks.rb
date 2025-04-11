module Denko
  module Behaviors
    module Callbacks
      include Lifecycle
      include State

      after_initialize do
        @callback_mutex = Denko.cruby? ? Denko::MutexStub.new : Mutex.new
        callbacks
      end

      def callbacks
        @callbacks ||= {}
      end

      def add_callback(key=:persistent, &block)
        @callback_mutex.lock
        @callbacks      ||= {}
        @callbacks[key] ||= []
        @callbacks[key] << block
        @callback_mutex.unlock
        @callbacks
      end

      def remove_callback(key=nil)
        @callback_mutex.lock
        (@callbacks && key) ? @callbacks.delete(key) : @callbacks = {}
        @callback_mutex.unlock
        @callbacks
      end

      alias :on_data :add_callback
      alias :remove_callbacks :remove_callback

      def update(data)
        # nil will unblock #read without running callbacks.
        unless data
          remove_callback(:read)
          return nil
        end

        filtered_data = pre_callback_filter(data)

        # nil will unblock #read without running callbacks.
        unless filtered_data
          remove_callback(:read)
          return nil
        end

        @callback_mutex.lock
        if @callbacks && !@callbacks.empty?
          @callbacks.each_value do |array|
            array.each do |callback|
              callback.call(filtered_data)
            end
          end
          # Remove one-time callbacks added by #read.
          @callbacks.delete(:read)
        end
        @callback_mutex.unlock

        update_state(filtered_data)
      end

      # Override to process data before giving to callbacks and state.
      def pre_callback_filter(data)
        data
      end
    end
  end
end
