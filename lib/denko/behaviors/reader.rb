module Denko
  module Behaviors
    module Reader
      include Lifecycle
      include Callbacks

      #
      # DO NOT REPLACE with MutexStub on CRuby!
      # Even with GIL, misordered readings possible with multiple threads.
      #
      after_initialize do
        # mruby doesn't have Thread or Mutex, so only stub there.
        @reader_mutex = Denko.mruby? ? Denko::MutexStub.new : Mutex.new
      end

      READ_WAIT_TIME = 0.001
      #
      # Override #update to allow "raw reads" or "normal reads":
      #
      #   - Normal reads perform normal #update behavior, passing through
      #     #pre_callback_filter, running all callbacks and returning filtered_data.
      #     Use normal for anything that updates the state of a component, and handle
      #     that in in #pre_callback_filter and #update_state.
      #     May or may not block calling thread, depending on platform.
      #
      #   - Raw reads bypass #pre_callback_filter, callbacks, and return
      #     raw data. Use raw for reading things like sensor config/serial etc.
      #     DOES NOT take block callbacks from the use. ALWAYS handle the return value.
      #     ALWAYS blocks the calling thread.
      #
      def update(data)
        if @reading_raw
          @callback_mutex.lock
          @callbacks[:read_raw].each { |c| c.call(data) }
          @callbacks.delete(:read_raw)
          @callback_mutex.unlock
          @reading_raw = false
          data
        else
          return_value = super(data)
          @reading_normally = false
          return_value
        end
      end

      #
      # Delegates to #_read. Data passes through #pre_callback_filter, runs all
      # callbacks, and @state is set. BLOCKS calling thread.
      #
      def read(*args, **kwargs, &block)
        read_using(self.method(:_read), *args, **kwargs, &block)
      end

      #
      # Delegates to #_read. Data passes through #pre_callback_filter, runs all
      # callbacks, and @state is set. DOES NOT BLOCK calling thread.
      #
      def read_nb(*args, **kwargs, &block)
        @reader_mutex.lock
        sleep READ_WAIT_TIME while read_busy?
        @reading_normally = true
        _read(*args, **kwargs, &block)
        @reader_mutex.unlock
      end

      #
      # NEVER call this directly. Use #read_nb instead.
      #
      # Define #_read in including class to get data which updates the
      # peripheral state. See #read_using comments for more info.
      #
      def _read
        raise NotImplementedError.new("#{self.class.name}#_read is not defined.")
      end

      #
      # Take a proc/lambda/method as the first agrument and use it to read.
      # Arguments are passed through, allowing dynamic read methods to be defined.
      # Eg. send commands (in args) to a bus, then wait for data read back.
      #
      # Data is received when the board/bus calls #update on us. If a read was
      # started by this method, the data will pass through #pre_callback_filter,
      # trigger all callbacks, and set @state. Use this for reading the state
      # of peripherals, like digital pin level, enviro sensor reading etc.
      #
      def read_using(reader, *args, **kwargs, &block)
        # Lock, THEN wait for other normal reads to finish.
        @reader_mutex.lock
        sleep READ_WAIT_TIME while read_busy?
        @reading_normally = true

        # One-time callbacks.
        return_value = nil
        add_callback(:read) { |filtered_data| return_value = filtered_data }
        add_callback(:read, &block) if block_given?

        reader.call(*args, **kwargs)
        @reader_mutex.unlock

        # Wait for #update to remove the :read callbacks (return_value is set).
        sleep READ_WAIT_TIME while callbacks[:read]
        return_value
      end

      #
      # Similar to #read_using, but does not trigger #pre_callback_filter,
      # or run any callbacks except :read_raw. BLOCKS calling thread.
      # Use for things like sensor status, config etc.
      #
      def read_raw(reader, *args, **kwargs)
        # Can't guarantee read order.
        raise StandardError, "#read_raw unavailable while listening" if @listening

        # Lock, THEN wait for any normal read to finish.
        @reader_mutex.lock
        sleep READ_WAIT_TIME while read_busy?
        @reading_raw = true

        # Special :read_raw one-time callback.
        return_value = nil
        add_callback(:read_raw) { |bytes| return_value = bytes }

        # Call reader, but block and keep the lock until :read_raw callback gets run.
        reader.call(*args, **kwargs)
        sleep READ_WAIT_TIME while callbacks[:read_raw]
        @reader_mutex.unlock

        return_value
      end

      def read_busy?
        @reading_normally || @reading_raw
      end
    end
  end
end
