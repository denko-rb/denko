module Denko
  class Board
    def show_ws2812(pin, pixel_buffer)
      # ALWAYS have first 4 bytes set to 0. ESP32 crashes without this!
      # Last 4 bytes will be settings, but not yet. Just 24-bit 800 kHz for now.
      settings    = pack :uint8, [0, 0, 0, 0, 0, 0, 0, 0]

      pixel_bytes = pack :uint8, pixel_buffer
      
      write_and_halt Message.encode command: 19,
                                    pin: pin,
                                    value: pixel_buffer.length,
                                    aux_message: settings + pixel_bytes
    end
  end
end
