module Denko
  module Behaviors
    module Lifecycle
      #
      # Callback hook DSL for setup work in including classes.
      # include(Component) in final classes to get callbacks methods.
      #
      def self.included(base); base.extend ClassMethods; end
      #
      CALLBACK_METHODS = [:before_initialize, :after_initialize]

      # Callback methods themselves.
      module ClassMethods
        CALLBACK_METHODS.each do |method_sym|
          civar_sym = "@#{method_sym}_cbs".to_sym
          define_method(method_sym) do |&block|
            if self.instance_variable_defined?(civar_sym)
              blocks = self.instance_variable_get(civar_sym)
            else
              blocks = []
            end
            blocks << block
            self.instance_variable_set(civar_sym, blocks)
          end
        end
      end

      # Instance method runners.
      CALLBACK_METHODS.each do |method_sym|
        civar_sym  = "@#{method_sym}_cbs".to_sym
        runner_sym = "run_#{method_sym}_cbs".to_sym

        define_method(runner_sym) do
          # Need to check civars in ancestors too.
          klasses = self.class.ancestors
          # If running "after" reverse hierarchy so they run top-down.
          klasses = klasses.reverse if method_sym.to_s[0..4] == "after"

          blocks = []
          klasses.each do |klass|
            if klass.instance_variable_defined?(civar_sym)
              blocks << klass.instance_variable_get(civar_sym)
            end
          end
          blocks = blocks.flatten
          blocks.each { |b| instance_exec(&b) }
        end
      end
    end
  end
end
