require_relative "board"

class Game
  attr_reader :hidden_board, :mine_count, :mine_map, :size, :visible_board
  def initialize(size, mine_count = 0)
    @size = size
    @mine_count = mine_count.zero? ? size : mine_count
    @visible_board = Board.new(size, "■")
  end

end
