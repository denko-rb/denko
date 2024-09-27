# Require all files in board folder relative to this file.
Dir["#{Denko.root}/lib/denko/board/*.rb"].each { |file| require file }

module Denko
  class Board
    attr_reader :name, :version, :serial_buffer_size, :aux_limit, :eeprom_length, :i2c_limit
    attr_reader :low, :high, :analog_write_resolution, :analog_read_resolution, :analog_write_high, :analog_read_high

    def initialize(connection, options={})
      # Shake hands
      @connection = connection
      ack = connection.handshake

      # Split handshake acknowledgement into separate values.
      @name, @version, @serial_buffer_size, @aux_limit, @eeprom_length, @i2c_limit = ack.split(",")

      # Tell connection how much serial buffer the board has, for flow control.
      @serial_buffer_size = @serial_buffer_size.to_i
      raise StandardError, "no serial buffer size given in handshake" if @serial_buffer_size < 1
      @connection.remote_buffer_size = @serial_buffer_size

      # Load board map by name.
      @name = nil if @name.empty?
      load_map(@name)

      # Leave room for null termination of aux messages.
      @aux_limit = @aux_limit.to_i - 1

      # Set I2C transaction size limit. Safe minimum is 32.
      # This makes I2C fail silently if board does not implement.
      @i2c_limit = @i2c_limit.to_i
      @i2c_limit = 32 if @i2c_limit == 0

      # Remaining settings
      @version       = nil if @version.empty?
      @eeprom_length = @eeprom_length.to_i

      # connection calls #update on board when data is received.
      connection.add_observer(self)

      # Set digital and analog IO levels.
      @low  = 0
      @high = 1
      self.analog_write_resolution = options[:write_bits] || 8
      self.analog_read_resolution  = options[:read_bits]  || 10
    end

    def finish_write
      sleep 0.001 while @connection.writing?
      write "\n91\n"
      sleep 0.001 while @connection.writing?
    end

    def analog_write_resolution=(value)
      set_analog_write_resolution(value)
      @analog_write_resolution = value
      @analog_write_high = (2 ** @analog_write_resolution) - 1
    end

    def analog_read_resolution=(value)
      set_analog_read_resolution(value)
      @analog_read_resolution = value
      @analog_read_high = (2 ** @analog_read_resolution) - 1
    end

    alias :pwm_high :analog_write_high
    alias :dac_high :analog_write_high
    alias :adc_high :analog_read_high

    def write(msg)
      @connection.write(msg)
    end

    #
    # Use Board#write_and_halt to call C++ board functions that disable interrupts
    # for a long time. "Long" being more than 1 serial character (~85us for 115200 baud).
    #
    # The "halt" part tells the Connection to halt transmission to the board after this message.
    # Since it expects interrupts to be disabled, any data sent could be lost.
    #
    # When the board function has re-enabled interrupts, it should call sendReady(). That
    # signal is read by the Connection, telling it to resume transmisison.
    #
    def write_and_halt(msg)
      @connection.write(msg, true)
    end

    #
    # Use standard Subcomponents behavior.
    #
    include Behaviors::Subcomponents

    def update(line)
      pin, message = line.split(":", 2)

      # Handle messages from hardware I2C buses.
      match = pin.match /\AI2C(\d*)/
      if match
        dev_index = match[1].to_i
        dev = hw_i2c_devs[dev_index]
        dev.update(message) if dev
        return
      end

      pin = pin.to_i
      if single_pin_components[pin]
        single_pin_components[pin].update(message)
      end
    end

    #
    # Component generating convenience methods. TODO: add more!
    #
    def eeprom
      raise StandardError, 'board has no built-in EEPROM, or EEPROM disabled in sketch' if @eeprom_length == 0
      @eeprom ||= EEPROM::BuiltIn.new(board: self)
    end
  end
end
