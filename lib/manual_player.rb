require_relative 'game'

class ManualPlayer
  attr_reader :game, :header_row, :header_column

  def initialize(game)
    @game = game
    @header_row = "  |" + spaced_index_strings(game.size).join("|")
    @header_column = spaced_index_strings(game.size)
  end

  def manual_play
    loop do
      play_a_turn
      break if game.game_over?
    end
    display_final_results
  end

  def play_a_turn
    clear_screen
    display_visible_board
    puts 'What row?'
    row = gets.chomp.to_i
    puts 'What column?'
    column = gets.chomp.to_i
    game.choose(row, column)
  end

  def display_final_results
    clear_screen
    display_visible_board
    puts game.won? ? "YOU WON!" : "YOU LOST!"
  end

  def display_visible_board(visible_board = game.visible_board)
    puts header_row
    visible_board.each_with_index do |row, index|
      puts header_column[index] + "| " + row.join("  ")
    end
  end

  private

  def clear_screen
    puts `clear`
  end

  def spaced_index_strings(size)
    (0...size).to_a.map(&:to_s).map{|n| n.length == 1 ? n.prepend(" ") : n }
  end
end
