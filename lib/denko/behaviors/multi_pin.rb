module Denko
  module Behaviors
    module MultiPin
      #
      # Model complex components, using multiple pins, by using proxy components
      # with one pin each.
      #
      include Component
      include Lifecycle

      attr_reader :pin, :pins, :proxies

      def proxies
        @proxies ||= {}
      end

      # Return a hash with the state of each proxy component.
      def proxy_states
        hash = {}
        proxies.each_key do |key|
          hash[key] = proxies[key].state if self.proxies[key]
        end
        hash
      end

      def convert_pins
        @pins = {}
        params[:pins].each do |key,pin|
          self.pins[key] = pin ? board.convert_pin(pin) : nil
        end
        pin_array = pins.values
        raise ArgumentError, "duplicate pins in: #{pins.inspect}" unless pin_array == pin_array.uniq
      end

      #
      # Proxy a pin to a single-pin component. Set this up in the including
      # component's #initialize_pins method. Additional options for each proxy
      # (eg. mode: :input_pullup) can be injected there.
      #
      def proxy_pin(name, klass, pin_options={})
        # Proxied pins are required by default.
        require_pin(name) unless pin_options[:optional]

        # Make the proxy, passing through options, and store it.
        if self.pins[name]
          # Allow pin_options to override board or pin number.
          proxy_options = pin_options
          proxy_options[:board] ||= self.board
          proxy_options[:pin]   ||= self.pins[name]

          proxy = klass.new(proxy_options)
          self.proxies[name] = proxy
          instance_variable_set("@#{name}", proxy)
        end

        # Accessor for the proxy's instance var, or nil, if not given.
        singleton_class.class_eval { attr_reader name }
      end

      #
      # Require a single pin that may or may not be proxied. This is useful for
      # components using libraries running on the board, where we need to specify
      # the pin, but not do anything with it.
      #
      def require_pin(name)
        raise ArgumentError, "missing #{name.inspect} pin" unless self.pins[name]
      end

      def require_pins(*array)
        [array].flatten.each { |name| require_pin(name) }
      end
    end
  end
end
