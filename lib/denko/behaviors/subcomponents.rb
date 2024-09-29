module Denko
  module Behaviors
    module Subcomponents
      #
      # Main Methods
      #
      def add_component(component)
        add_single_pin(component)
        add_hw_i2c(component)
        add_hw_spi(component)
        components << component
      end

      def remove_component(component)
        remove_single_pin(component)
        remove_hw_i2c(component)
        remove_hw_spi(component)
        deleted = components.delete(component)
        component.stop if deleted && component.respond_to?(:stop)
      end

      def components
        @components ||= []
      end

      #
      # Single Pin
      #
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

      def remove_single_pin(component)
        if component.respond_to?(:pin) && component.pin.class == Integer
          single_pin_components.delete(component.pin)
        end
      end

      def single_pin_components
        @single_pin_components ||= {}
      end

      #
      # I2C
      #
      def add_hw_i2c(component)
        if component.respond_to?(:i2c_index)
          unless hw_i2c_comps[component.i2c_index]
            hw_i2c_comps[component.i2c_index] = component
          else
            raise StandardError,  "Error adding #{component} to #{self}. I2C dev: #{component.i2c_index} " \
                                  "already in use by: #{hw_i2c_comps[component.i2c_index]}"
          end
        end
      end

      def remove_hw_i2c(component)
        hw_i2c_comps.delete(component.i2c_index) if component.respond_to?(:i2c_index)
      end

      def hw_i2c_comps
        @hw_i2c_comps ||= {}
      end

      #
      # SPI
      #
      def add_hw_spi(component)
        if component.respond_to?(:spi_index)
          unless hw_spi_comps[component.spi_index]
            hw_spi_comps[component.spi_index] = component
          else
            raise StandardError,  "Error adding #{component} to #{self}. SPI dev: #{component.spi_index} " \
                                  "already in use by: #{hw_spi_comps[component.spi_index]}"
          end
        end
      end

      def remove_hw_spi(component)
        hw_spi_comps.delete(component.spi_index) if component.respond_to?(:spi_index)
      end

      def hw_spi_comps
        @hw_spi_comps ||= {}
      end
    end
  end
end
