module Denko
  module I2C
    module Peripheral
      include Behaviors::BusPeripheralAddressed
      include Behaviors::Reader

      #
      # DSL to set I2C defaults when a Peripheral includes this Module.
      #
      def self.included(klass)
        klass.extend ClassMethods
      end

      I2C_DEFAULTS = [:@i2c_address, :@i2c_frequency, :@i2c_repeated_start]

      module ClassMethods
        I2C_DEFAULTS.each do |ivar_sym|
          getter_sym = ivar_sym.to_s.gsub("@", "").to_sym
          setter_sym = getter_sym.to_s.gsub("i2c_", "i2c_default_").to_sym

          # Class ivar setter per subclass: SubClass.i2c_default_{NAME} VALUE
          define_method(setter_sym) do |value|
            self.instance_variable_set(ivar_sym, value)
          end
        end
      end

      #
      # Instance Methods
      #

      # No getters at the class level. Instead look for ivar set in singleton first, then class.
      def i2c_defaults
        hash = { frequency: 100_000, repeated_start: false }
        I2C_DEFAULTS.each do |ivar_sym|
          hash_sym = ivar_sym.to_s.gsub("@i2c_", "").to_sym
          hash[hash_sym] = self.class.instance_variable_get(ivar_sym)      if self.class.instance_variable_defined?(ivar_sym)
          hash[hash_sym] = singleton_class.instance_variable_get(ivar_sym) if singleton_class.instance_variable_defined?(ivar_sym)
        end
        hash
      end

      def before_initialize(options={})
        # Use @address instead of @i2c_address for default BusPeripheral behavior.
        @address            = options[:i2c_address]        || options[:address]        || i2c_defaults[:address]
        @i2c_frequency      = options[:i2c_frequency]      || options[:frequency]      || i2c_defaults[:frequency]
        @i2c_repeated_start = options[:i2c_repeated_start] || options[:repeated_start] || i2c_defaults[:repeated_start]
        super(options)
      end

      alias :i2c_address :address
      attr_accessor :i2c_repeated_start, :i2c_frequency

      def i2c_write(bytes=[])
        bus.write(i2c_address, bytes, i2c_frequency, i2c_repeated_start)
      end

      def i2c_read(num_bytes, register: nil)
        bus._read(i2c_address, register, num_bytes, i2c_frequency, i2c_repeated_start)
      end
    end
  end
end
