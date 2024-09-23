module Denko
  module I2C
    module Peripheral
      include Behaviors::BusPeripheralAddressed
      include Behaviors::Reader

      I2C_ADDRESS         = nil
      I2C_FREQUENCY       = 100_000
      I2C_REPEATED_START  = false

      # Define I2C defaults in subclasses by overriding the constants above.
      def i2c_default(sym)
        const_sym = "I2C_#{sym}".upcase.to_sym
        self.class.const_get(const_sym) if self.class.const_defined?(const_sym)
      end

      def before_initialize(options={})
        # Use @address instead of @i2c_address for default BusPeripheral behavior.
        @address            = options[:i2c_address]        || options[:address]        || i2c_default(:address)
        @i2c_frequency      = options[:i2c_frequency]      || options[:frequency]      || i2c_default(:frequency)
        @i2c_repeated_start = options[:i2c_repeated_start] || options[:repeated_start] || i2c_default(:repeated_start)
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
