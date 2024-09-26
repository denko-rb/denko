module Denko
  module Behaviors
    module Subcomponents
      def components
        @components ||= []
      end

      def single_pin_components
        @single_pin_components ||= {}
      end

      def hw_i2c_devs
        @hw_i2c_devs ||= {}
      end

      def add_component(component)
        add_single_pin(component)
        add_hw_i2c(component)
        components << component
      end

      def remove_component(component)
        remove_single_pin(component)
        remove_hw_i2c(component)
        deleted = components.delete(component)
        component.stop if deleted && component.respond_to?(:stop)
      end

      def add_single_pin(component)
        if component.respond_to?(:pin) && component.pin.class == Integer
          unless single_pin_components[component.pin]
            single_pin_components[component.pin] = component
          else
            raise StandardError,  "Error adding #{component} to #{self}. Pin: #{component.pin} " \
                                  "already in use by: #{single_pin_components[component.pin]}"
          end
        end
      end

      def add_hw_i2c(component)
        if component.respond_to?(:i2c_index)
          unless hw_i2c_devs[component.i2c_index]
            hw_i2c_devs[component.pin] = component
          else
            raise StandardError,  "Error adding #{component} to #{self}. I2C dev: #{component.i2c_index} " \
                                  "already in use by: #{hw_i2c_devs[component.pin]}"
          end
        end
      end

      def remove_single_pin(component)
        if component.respond_to?(:pin) && component.pin.class == Integer
          single_pin_components.delete(component.pin)
        end
      end

      def remove_hw_i2c(component)
        hw_i2c_devs.delete(component.i2c_index) if component.respond_to?(:i2c_index)
      end
    end
  end
end
