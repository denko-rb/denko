module Denko
  module Behaviors
    module BusController
      include Component
      include Subcomponents

      def mutex
        # mruby doesn't have Thread or Mutex, so only stub there.
        @mutex ||= Denko.mruby? ? Denko::MutexStub.new : Mutex.new
      end
    end
  end
end
