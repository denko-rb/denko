module Denko
  module OneWire
    class Helper
      def self.address_to_bytes(address)
        bytes = []
        8.times { |i| bytes[i] = address >> (8*i) & 0xFF }
        bytes
      end

      def self.crc(data)
        calculated, received = self.calculate_crc(data)
        calculated == received
      end
      
      def self.calculate_crc(data)
        if data.class == Integer
          bytes = address_to_bytes(data)
        else
          bytes = data
        end

        crc = 0b00000000
        bytes.take(bytes.length - 1).each do |byte|
          for bit in (0..7)
            xor = ((byte >> bit) & 0b1) ^ (crc & 0b1)
            crc = crc ^ ((xor * (2 ** 3)) | (xor * (2 ** 4)))
            crc = crc >> 1
            crc = crc | (xor * (2 ** 7))
          end
        end
        [crc, bytes.last]
      end
    end
  end
end
