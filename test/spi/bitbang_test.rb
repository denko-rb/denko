require_relative '../test_helper'

class TempSpiPeripheral
  include Denko::SPI::Peripheral
end

class SPIBitBangTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @bus ||= Denko::SPI::BitBang.new(board: board, pins: {mosi: 4, miso: 5, clock: 6})
  end

  def test_no_miso
    no_miso = Denko::SPI::BitBang.new(board: board, pins: {mosi: 4, clock: 6})
    refute no_miso.params[:pins][:input]
    refute no_miso.pins[:input]
  end

  def test_no_mosi
    no_mosi = Denko::SPI::BitBang.new(board: board, pins: {miso: 5, clock: 6})
    refute no_mosi.params[:pins][:output]
    refute no_mosi.pins[:output]
  end
end
