module Denko
  module Behaviors
    module Reader
      include Lifecycle
      include Callbacks

      READ_WAIT_TIME = 0.001

      attr_reader :state_mutex

      after_initialize do
        @read_type    = :idle
        @read_result  = nil
        @state_mutex  = Denko.mruby? ? Denko::MutexStub.new : Mutex.new
      end

      # Define #_read in including class to update the component's state.
      def _read
        raise NotImplementedError.new("#{self.class.name}#_read is not defined.")
      end

      #
      # Take a proc/lambda/method and call it to read.
      # Arguments are passed through, allowing dynamic read methods to be defined.
      # Eg. send commands (in args) to a bus, then wait for data read back.
      #
      # Data is received when the board/bus calls our #update. If a read was
      # started by this method, the data will pass through #pre_callback_filter,
      # trigger all callbacks, and set @state. Use this for reading the state
      # of peripherals, like digital pin level, enviro sensor reading etc.
      #
      def read_using(reader_method, &block)
        @state_mutex.lock
          @read_type = :regular
          reader_method.call
          sleep READ_WAIT_TIME while (@read_type != :idle)
          block.call(@read_result) if block_given?
        @state_mutex.unlock

        @read_result
      end

      # Default read method to be called by user.
      def read(&block)
        read_using(self.method(:_read), &block)
      end

      #
      # Similar to #read_using, but #update will not filter data or run callbacks.
      # Always blocks calling thread. Use for things like sensor status, config etc.
      #
      def read_raw(reader_method)
        # Can't guarantee read order.
        raise StandardError, "#read_raw unavailable while listening" if @listening

        @state_mutex.lock
          @read_type = :raw
          reader_method.call
          sleep READ_WAIT_TIME while (@read_type != :idle)
        @state_mutex.unlock

        @read_result
      end

      #
      # Override #update to allow :raw or :regular reads:
      #   - For :regular reads, see #read, and #read_using
      #   - For :raw reads see #read_raw
      #
      def update(data)
        # If a read is in progress, let that method lock and unlock @state_mutex.
        # Only lock/unlock here if no read was requested. Probably a listener.
        read_in_progress = @read_type != :idle

        @state_mutex.lock unless read_in_progress

        @read_result = (@read_type == :raw) ? data : super(data)
        @read_type = :idle

        @state_mutex.unlock unless read_in_progress

        @read_result
      end
    end
  end
end
