module Denko
  module Behaviors
    #
    # This module provides a standardized state management interface
    # for {Component}. It typically stores things like sensor readings
    # or the present level (high or low) of a digital output.
    #
    # @example Digital Output
    #   class Output
    #     include Behaviors::OutputPin
    #
    #     def low
    #       board.digital_write(@pin, 0)
    #       self.state = 0
    #     end
    #
    #     def high
    #       board.digital_write(@pin, 1)
    #       self.state = 1
    #     end
    #   end
    #
    module State
      include Lifecycle

      # @return [Object] Current state of the component
      attr_accessor :state

      # @note This method, **not** `#state=` is called in `#update` when reading a component.
      #
      # Called by the board to update the component state when read.
      #
      # The default implementation simply sets the `@state` instance variable
      # to the given value. When component state is represented by a more
      # complex data structure (eg. `Array` or `Hash`), this should be overridden so
      # its elements are updated in place, and memory (re)allocation is avoided
      # on constrained platforms, such as microcontrollers running mruby.
      #
      # @example Sensor with Hash state
      #   class Sensor
      #     include Denko::Behaviors::State
      #     include Denko::Behaviors::Lifecycle
      #
      #     # Initialize hash once.
      #     after_initialize do
      #       @state = { temperature: nil, humidity: nil, timestamp: nil }
      #     end
      #
      #     # Change hash values in place for better performance.
      #     def update_state(reading)
      #       @state[:temperature] = reading[:temperature]
      #       @state[:humidity] = reading[:temperature]
      #       @state[:timestamp] = Time.now
      #     end
      #   end
      #
      def update_state(value)
        @state = value
      end
    end
  end
end
