# encoding: ascii-8bit
# For convenience when validating longer data types.

require_relative '../test_helper'

class APISPITest < Minitest::Test
  include TestPacker

  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Denko::Board.new(connection)
  end

  def header_args
    length = board.aux_limit - 8

    [nil, Array.new(length){0}, length, 1000000, 0, :msbfirst]
  end

  def test_spi_modes
    # Default to mode 0.
    assert_equal (pack :uint8, 0b10000000), board.spi_header(*header_args)[0]

    args = header_args.tap { |a| a[4] = 1 }
    assert_equal (pack :uint8, 0b10000001), board.spi_header(*args)[0]

    args = header_args.tap { |a| a[4] = 2 }
    assert_equal (pack :uint8, 0b10000010), board.spi_header(*args)[0]

    args = header_args.tap { |a| a[4] = 3 }
    assert_equal (pack :uint8, 0b10000011), board.spi_header(*args)[0]

    args = header_args.tap { |a| a[4] = 4 }
    assert_raises(ArgumentError) { board.spi_header(*args) }
  end

  def test_spi_lsbfirst
    # Default to :msbfirst
    assert_equal (pack :uint8, 0b10000000), board.spi_header(*header_args)[0]

    args = header_args.tap { |a| a[5] = :lsbfirst }
    assert_equal (pack :uint8, 0b00000000), board.spi_header(*args)[0]
  end

  def test_spi_frequency
    # Default to 1 MHz.
    assert_equal (pack :uint32, 1_000_000), board.spi_header(*header_args)[4..7]

    args = header_args.tap { |a| a[3] = 8_000_000 }
    assert_equal (pack :uint32, 8_000_000), board.spi_header(*args)[4..7]
  end

  def test_spi_too_many_bytes
    # Default args have maximum read and write based on aux_limit.
    board.spi_header(*header_args)

    # Too many write
    args = header_args.tap { |a| a[1] << 0 }
    assert_raises(ArgumentError) { board.spi_header(*args) }

    # Too many read
    args = header_args.tap { |a| a[2] += 1 }
    assert_raises(ArgumentError) { board.spi_header(*args) }
  end

  def test_spi_no_bytes
    assert_raises(ArgumentError) { board.spi_transfer(3, read: 0) }
    assert_raises(ArgumentError) { board.spi_listen(3, read: 0) }
  end

  def test_spi_bad_frequency
    assert_raises(ArgumentError) { board.spi_transfer(3, read: 0, frequency: "string") }
  end

  def test_spi_transfer
    board
    bytes = [1,2,3,4]
    header = board.spi_header(3, bytes, 4, 8000000, 2, :lsbfirst)
    aux = header + pack(:uint8, bytes)
    mock = Minitest::Mock.new.expect  :call, nil,
                                      [Denko::Message.encode(command: 26, pin: 3, aux_message: aux)]

    board.stub(:write, mock) do
      args = { write: [1,2,3,4], read: 4, bit_order: :lsbfirst, frequency: 8000000, mode: 2 }
      board.spi_transfer(0, 3, **args)
    end
    mock.verify
  end

  def test_spi_listen
    board
    header = board.spi_header(3, [], 8, 1000000, 0, :lsbfirst)
    mock = Minitest::Mock.new.expect  :call, nil,
                                      [Denko::Message.encode(command: 27, pin: 3, aux_message: header)]

    board.stub(:write, mock) do
      board.spi_listen(0, 3, read: 8, bit_order: :lsbfirst)
    end
    mock.verify
  end

  def test_spi_stop
    board
    mock = Minitest::Mock.new.expect :call, nil, [Denko::Message.encode(command: 28, pin: 3)]
    board.stub(:write, mock) do
      board.spi_stop(3)
    end
    mock.verify
  end
end
