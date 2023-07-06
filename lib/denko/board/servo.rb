module Denko
  class Board
    # CMD = 10
    def servo_toggle(pin, value=:off, min: 544, max: 2400)
      write Message.encode  command: 10,
                            pin: pin,
                            value: (value == :off) ? 0 : 1,
                            aux_message: pack(:uint16, [min, max])
    end

    # CMD = 11
    def servo_write(pin, value=0)
      write Message.encode  command: 11,
                            pin: pin,
                            aux_message: pack(:uint16, value)
    end
  end
end
