module Denko
  class MutexStub
    def synchronize(&block)
      block.call
    end

    def lock
    end

    def unlock
    end
  end
end
