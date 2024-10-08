require_relative '../test_helper'

class APIInfraredTest < Minitest::Test
  include TestPacker
  
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Denko::Board.new(connection)
  end
  
  def test_infrared_emit
    board
    aux = pack(:uint16, 4) + pack(:uint16, [255,0,255,0])
    message = Denko::Message.encode command: 16, pin: 8, value: 38, aux_message: aux
    
    mock = Minitest::Mock.new.expect :call, nil, [message]
    connection.stub(:write, mock) do
      board.infrared_emit 8, 38, [255,0,255,0]
    end
    mock.verify
  end
  
  def test_minimum_pulses
    assert_raises(ArgumentError) do
      board.infrared_emit 8, 38, []
    end
  end
  
  def test_maximum_pulses
    assert_raises(ArgumentError) do 
      board.infrared_emit 8, 38, Array.new(513) { 128 }
    end
  end
end
