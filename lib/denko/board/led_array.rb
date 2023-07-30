module Denko
  class Board
    def show_ws2812(pin, pixel_count, pixel_buffer)
      # Settings are blank for now.
      settings = pack :uint8, [0, 0, 0, 0]
      
      packed_pixels = pack :uint8, pixel_buffer
      
      write_and_halt Message.encode command: 19,
                                    pin: pin,
                                    value: pixel_count,
                                    aux_message: settings + packed_pixels
    end
  end
end
