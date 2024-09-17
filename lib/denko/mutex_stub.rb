module Denko
  class MutexStub
    def synchronize(&block)
      block.call
    end
  end
end
