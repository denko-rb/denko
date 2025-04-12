module Denko
  module Behaviors
    module Threaded
      attr_reader :thread, :interrupts_enabled

      module ClassMethods
        def interrupt_with(*args)
          interrupts = self.class_eval('@@interrupts') rescue []
          interrupts = (interrupts + args).uniq
          self.class_variable_set(:@@interrupts, interrupts)
        end
      end

      def mruby_thread_check
        if Denko.mruby?
          raise NotImplementedError, "threads unavailable in mruby "
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      def threaded(&block)
        mruby_thread_check
        stop_thread
        enable_interrupts unless interrupts_enabled
        @thread = Thread.new(&block)
      end

      def threaded_loop(&block)
        mruby_thread_check
        threaded do
          loop(&block)
        end
      end

      def stop_thread
        mruby_thread_check
        @thread.kill if @thread
      end

      def stop
        stop_thread unless Denko.mruby?
        begin; super; rescue NoMethodError; end
      end

      def enable_interrupts
        unless Denko.mruby?
          interrupts = self.class.class_eval('@@interrupts') rescue []
          interrupts.each do |method_name|
            standard_method = self.method(method_name)

            singleton_class.send(:define_method, method_name) do |*args|
              stop_thread unless (Thread.current == @thread)
              standard_method.call(*args)
            end
          end
        end

        @interrupts_enabled = true
      end
    end
  end
end
