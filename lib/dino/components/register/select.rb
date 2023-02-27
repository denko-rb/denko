module Dino
  module Components
    module Register
      class Select
        #
        # Register select is an active-low output pin, used to select a device
        # on a bus for access. For input registers, the board sends bytes
        # as if they were coming from this pin. Each register uses a unique
        # select pin, so we can identify which Register object the incoming bytes
        # belong to. Devices on the same bus share the clock and data pins.
        #
        # There is no need to write this pin directly, but it must be in output
        # mode, and must include Callbacks to receieve updates.
        #
        include Setup::SinglePin
        include Setup::Output
        include Mixins::Callbacks
      end
    end
  end
end