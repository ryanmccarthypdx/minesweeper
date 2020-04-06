require_relative "board"

class Game
  attr_reader :hidden_board, :mine_count, :mine_map, :size, :visible_board
  def initialize(size, mine_count = 0)
    @size = size
    @mine_count = mine_count.zero? ? size : mine_count
    @visible_board = Board.new(size, "■")
  end

  def generate_hidden_board(forbidden_row, forbidden_column)
    @hidden_board = Board.new(size, 0)
    @mine_map = generate_mine_map(forbidden_row, forbidden_column)
    apply_mines!
    make_counts!
  end

private

  def generate_mine_map(forbidden_row, forbidden_column)
    output = []
    until output.count == mine_count do
      proposed = [rand(0...size), rand(0...size)]
      next if proposed == [forbidden_row, forbidden_column]
      output << proposed
      output.uniq!
    end
    output
  end

  def make_counts!
    hidden_board.all_coordinates.each do |row, column|
      next if hidden_board[row][column] == "*"
      hidden_board[row][column] = hidden_board.neighbors(row, column).values.count("*")
    end
  end

  def apply_mines!
    mine_map.each do |row, column|
      hidden_board[row][column] = "*"
    end
  end
end
