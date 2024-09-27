module Denko
  module I2C
    module Peripheral
      include Behaviors::BusPeripheralAddressed
      include Behaviors::Reader
      include Behaviors::Lifecycle

      # Set I2C defaults for including classes by defining these constants in them.
      I2C_ADDRESS         = nil
      I2C_FREQUENCY       = 100_000
      I2C_REPEATED_START  = false

      def i2c_default(sym)
        const_sym = "I2C_#{sym}".upcase.to_sym
        self.class.const_get(const_sym) if self.class.const_defined?(const_sym)
      end

       # Use @address instead of @i2c_address for default BusPeripheral behavior.
      def address
        @address ||= params[:i2c_address] || params[:address] || i2c_default(:address)
      end
      alias :i2c_address :address

      def i2c_frequency
        @i2c_frequency ||= params[:i2c_frequency] || params[:frequency] || i2c_default(:frequency)
      end

      def i2c_repeated_start
        return @i2c_repeated_start unless @i2c_repeated_start.nil?
        @i2c_repeated_start = params[:i2c_repeated_start]   if @i2c_repeated_start.nil?
        @i2c_repeated_start = params[:repeated_start]       if @i2c_repeated_start.nil?
        @i2c_repeated_start = i2c_default(:repeated_start)  if @i2c_repeated_start.nil?
        @i2c_repeated_start
      end

      attr_writer :i2c_frequency, :i2c_repeated_start

      def i2c_write(bytes=[])
        bus.write(i2c_address, bytes, i2c_frequency, i2c_repeated_start)
      end

      def i2c_read(num_bytes, register: nil)
        bus._read(i2c_address, register, num_bytes, i2c_frequency, i2c_repeated_start)
      end
    end
  end
end
