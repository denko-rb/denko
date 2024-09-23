module Denko
  module Sensor
    class DHT
      include Behaviors::SinglePin
      include Behaviors::Poller
      include TemperatureHelper

      def after_initialize(options={})
        # Set input mode to force upfront pin validation.
        self.mode = :input

        # Avoid repeated memory allocation for callback data and state.
        @reading   = { temperature: nil, humidity: nil }
      end

      def state
        state_mutex.synchronize { @state = { temperature: nil, humidity: nil } }
      end

      def _read
        board.pulse_read(pin, reset: board.low, reset_time: 20000, pulse_limit: 84, timeout: 100)
      end

      def pre_callback_filter(data)
        decode(data.split(",").map(&:to_i))
      end

      def decode(data)
        data = data.last(81)
        return { error: 'missing data' } unless data.length == 81
        data = data[0..79]

        bytes = []
        data.each_slice(16) do |b|
          byte = 0b00000000
          b.each_slice(2) do |x,y|
            bit = (y<x) ? 0 : 1
            byte = (byte << 1) | bit
          end
          bytes << byte
        end
        return { error: 'CRC failure' } unless crc(bytes)

        @reading[:temperature] = ((bytes[2] << 8) | bytes[3]).to_f / 10
        @reading[:humidity]    = ((bytes[0] << 8) | bytes[1]).to_f / 10

        @reading
      end

      def update_state(reading)
        state_mutex.synchronize do
          @state[:temperature] = reading[:temperature]
          @state[:humidity]    = reading[:humidity]
        end
      end

      def crc(bytes)
        bytes[0..3].reduce(0, :+) & 0xFF == bytes[4]
      end
    end
  end
end
