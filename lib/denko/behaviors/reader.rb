module Denko
  module Behaviors
    module Reader
      include Callbacks

      #
      # Default behavior for #read is to delegate to #_read.
      # Define #_read in including classes.
      #
      def read(*args, **kwargs, &block)
        read_using(self.method(:_read), *args, **kwargs, &block)
      end

      #
      # Take a proc/lambda/method as the first agrument and use it to read.
      # Arguments are passed through, allowing dynamic read methods to be defined.
      # Eg. send commands (in args) to a bus, then wait for data read back.
      # 
      # Block given is added as a one-time callback in the :read key, and 
      # the curent thread waits until data is received. Returns the result of
      # calling #pre_callback_filter with the data.
      #
      def read_using(reader, *args, **kwargs, &block)
        add_callback(:read, &block) if block_given?

        return_value = nil
        add_callback(:read) do |filtered_data|
          return_value = filtered_data
        end
        
        reader.call(*args, **kwargs)
        wait_for_read

        return_value
      end
      
      def wait_for_read
        loop do
          break if !callbacks[:read]
          sleep 0.001
        end
      end

      def _read
        raise NotImplementedError.new("#{self.class.name}#_read is not defined.")
      end
    end
  end
end
