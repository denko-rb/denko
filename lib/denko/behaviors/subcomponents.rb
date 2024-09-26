module Denko
  module Behaviors
    module Subcomponents
      def components
        @components ||= []
      end

      def single_pin_components
        @single_pin_components ||= {}
      end

      def add_component(component)
        # Prevent multiple I2C::Bus instances using one physical device.
        if component.respond_to?(:i2c_index)
          components.each do |other_component|
            if other_component.respond_to?(:i2c_index)
              if component.i2c_index == other_component.i2c_index
                raise StandardError, "I2C device index #{component.i2c_index} already in use by: #{other_component}"
              end
            end
          end
        end

        if component.respond_to?(:pin) && component.pin.class == Integer
          unless single_pin_components[component.pin]
            single_pin_components[component.pin] = component
          else
            raise StandardError,  "Error adding #{component} to #{self}. Pin: #{component.pin} " \
                                  "already in use by: #{single_pin_components[component.pin]}"
          end
        end

        components << component
      end

      def remove_component(component)
        if component.respond_to?(:pin) && component.pin.class == Integer
          single_pin_components[component.pin] = nil
        end

        deleted = components.delete(component)
        component.stop if deleted && component.respond_to?(:stop)
      end
    end
  end
end
