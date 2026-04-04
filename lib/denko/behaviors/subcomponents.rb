module Denko
  module Behaviors
    #
    # Keeps track of multiple downstream components connected to the including
    # component's physical interfaces. This mixin is typically included in a {Board},
    # {BoardProxy} or {BusController}.
    #
    # Subcomponents are indexed by the GPIO pin numbers they connect to, and indices
    # for hardware implemented interfaces (eg. SPI or I2C).
    #
    # - **Single Pin Components**: Indexed by pin number
    # - **Hardware I2C Interface**: Indexed by I2C device index, and pin numbers (if given)
    # - **Hardware SPI Interface**: Indexed by SPI device index, and pin numbers (if given)
    #
    # Conflicts are automatically prevented by raising an error when two
    # components are added with the same pin or index.
    #
    # @example Adding a single pin component
    #   board = Denko::Board.new(connection)
    #   led = Denko::LED.new(board: board, pin: 13)
    #   # board.single_pin_components[13] is now a reference to led
    #
    # @example Adding an I2C component
    #   i2c_bus = Denko::I2C::Bus.new(board: board, index: 1)
    #   # board.hw_i2c_comps[1] is now i2c_bus, an object that maps to board's 1st hardware I2C (/dev/i2c-0 on Linux)
    #
    # @example Preventing conflicts
    #   led1 = Denko::LED::Base.new(board: board, pin: 13)
    #   led2 = Denko::LED::Base.new(board: board, pin: 13)
    #   # => Raises StandardError: Pin 13 already in use
    #
    module Subcomponents
      # Register a child component to this parent component.
      #
      # @param component [Object] the child component to register
      # @return [Array] updated list of all this object's subcomponents
      # @raise [StandardError] if child component's pin or hardware bus index is already in use
      #
      # @see #remove_component
      #
      def add_component(component)
        if component.respond_to?(:i2c_index)
          i = component.i2c_index
          if hw_i2c_comps[i]
            raise StandardError, "Error adding #{component} to #{self}. HW I2C dev: #{i} in use by: #{hw_i2c_comps[i]}"
          else
            hw_i2c_comps[i] = component
          end
        end

        if component.respond_to?(:spi_index)
          i = component.spi_index
          if hw_spi_comps[i]
            raise StandardError, "Error adding #{component} to #{self}. HW SPI dev: #{i} in use by: #{hw_spi_comps[i]}"
          else
            hw_spi_comps[i] = component
          end
        end

        if component.respond_to?(:i2c_index) || component.respond_to?(:spi_index)
          # Allow hardware buses to reserve their pins to avoid conflicts.
          if component.respond_to?(:pins) && component.pins.class == Hash
            component.pins.values.each { |pin| add_component_to_pin(component, pin) }
          end
        elsif component.respond_to?(:pin) && component.pin.is_a?(Integer)
          # Standard SinglePin behavior.
          add_component_to_pin(component, component.pin)
        end

        components << component
      end

      # Deregister a child component from this parent component.
      #
      # This removes the subcomponent from all internal collections and
      # stops it if it responds to the `stop` method (useful for components
      # with continuous reading or background threads).
      #
      # @param component [Object] the component to remove
      # @return [Object, nil] the removed component, or nil if not found
      #
      def remove_component(component)
        if component.respond_to?(:i2c_index)
          hw_i2c_comps.delete(component.i2c_index)
        end

        if component.respond_to?(:spi_index)
          hw_spi_comps.delete(component.spi_index)
        end

        if component.respond_to?(:i2c_index) || component.respond_to?(:spi_index)
          # Allow hardware buses to reserve their pins to avoid conflicts.
          if component.respond_to?(:pins) && component.pins.class == Hash
            component.pins.values.each { |pin| remove_component_from_pin(pin) }
          end
        elsif component.respond_to?(:pin) && component.pin.is_a?(Integer)
          # Standard SinglePin behavior.
          remove_component_from_pin(component.pin)
        end

        deleted = components.delete(component)
        component.stop if deleted && component.respond_to?(:stop)
      end

      # @return [Array] all child components
      def components
        @components ||= []
      end

      # @return [Hash] child components using this parent component's pins, keyed by pin numbers
      def single_pin_components
        @single_pin_components ||= {}
      end

      # @return [Hash] child hardware I2C buses, keyed by index
      def hw_i2c_comps
        @hw_i2c_comps ||= {}
      end

      # @return [Hash] child hardware SPI buses, keyed by index
      def hw_spi_comps
        @hw_spi_comps ||= {}
      end

      private

      def add_component_to_pin(component, pin)
        if single_pin_components[pin]
          raise StandardError, "Error adding #{component} to #{self}. Pin: #{pin} already in use by: #{single_pin_components[pin]}"
        else
          single_pin_components[pin] = component
        end
      end

      def remove_component_from_pin(pin)
        single_pin_components.delete(pin)
      end
    end
  end
end
