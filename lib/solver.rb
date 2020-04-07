require_relative 'game'

class Solver
  attr_reader :game

  def initialize(game)
    @game = game
    choose_initial
  end

  def solve
    best_choices = find_best_choices_and_flag_mines
    if best_choices.any?
      best_choices.each{ |choice| game.choose(*choice) }
    else
      game.choose(*wild_guess)
    end
    return solve_until_won
  end

  def find_best_choices_and_flag_mines(visible_board = game.visible_board) # returns multiple if they are safe to click, otherwise an array of the one best choice
    best_choice = Hash.new{[]}

    all_coordinates.each do |row_index, column_index|
      cell = visible_board[row_index][column_index]

      next if [0, "■", "⚑"].include?(cell)

      neighbors = visible_board.neighbors(row_index, column_index)
      unclicked_neighbors = neighbors.select{|_,v| v == "■"}.keys
      next unless unclicked_neighbors.any?
      unaccounted_for_mines = (cell - neighbors.values.count("⚑"))

      risk = unaccounted_for_mines / unclicked_neighbors.count.to_f

      case risk
      when 1.0 # all unclicked are mines
        unclicked_neighbors.each{ |row, column| visible_board[row][column] = "⚑" }
        next
      when 0.0 # all unclicked are NOT mines
        best_choice[0] += unclicked_neighbors
        next
      else
        if risk <= (best_choice.keys.min || 1)
          best_choice[risk] = [unclicked_neighbors.first]
        else
          next
        end
      end
    end
    return best_choice[best_choice.keys.min].uniq
  end

  def solve_until_won
    if game.game_over?
      return game.won?
    else
      solve
    end
  end

  def wild_guess(visible_board = game.visible_board)
    return [0,0] if game.game_over? # prevent race condition
    raise StandardError, "Infinite loop initiated!" unless visible_board.flatten.include?("■")
    loop do
      candidate = all_coordinates.sample
      return candidate if visible_board[candidate[0]][candidate[1]] == "■"
    end
  end

  private

  def all_coordinates
    game.visible_board.all_coordinates
  end

  def choose_initial
    centerish = Array.new(2, game.size / 2)
    game.choose(*centerish)
  end
end
