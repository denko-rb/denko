module Denko
  module Behaviors
    module Callbacks
      include Lifecycle
      include State

      attr_reader :callbacks

      after_initialize do
        @callbacks = {}
      end

      def add_callback(key=:persistent, &block)
        @callbacks[key] ||= []
        @callbacks[key] << block
      end

      def remove_callback(key=nil)
        key ? @callbacks.delete(key) : @callbacks = {}
      end

      alias :on_data :add_callback
      alias :remove_callbacks :remove_callback

      def update(data)
        if data
          filtered_data = pre_callback_filter(data)
          if filtered_data
            unless @callbacks.empty?
              @callbacks.each_value do |array|
                array.each do |callback|
                  callback.call(filtered_data)
                end
              end
            end
            remove_callback(:read)
            return update_state(filtered_data)
          end
        end

        # No or invalid data. Remove :read callback anyway.
        remove_callback(:read)
        return nil
      end

      # Redefine this in classes to process data before it hits callback blocks and state.
      def pre_callback_filter(data)
        data
      end
    end
  end
end
