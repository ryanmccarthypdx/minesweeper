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

  def choose(row, column)
    generate_hidden_board(row, column) unless hidden_board

    return false unless visible_board.choice_valid?(row, column)

    hidden_value = hidden_board[row][column]
    case hidden_value
    when "*"
      @visible_board = hidden_board
      visible_board[row][column] = "☹️"
    when 0
      visible_board[row][column] = hidden_value
      reveal_neighbors!(row, column)
    else
      visible_board[row][column] = hidden_value
    end
  end

  def game_over?
    won? || lost?
  end

  def won?(population = visible_board.flatten)
    return false if lost?
    population.reject{|p| p.is_a?(Integer) }.count == mine_count
  end

  def lost?(population = visible_board.flatten)
    population.include?("☹️")
  end

private

  def reveal_neighbors!(row, column)
    visible_board.neighbor_coordinates(row, column).each do |row, column|
      choose(row, column)
    end
  end

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
