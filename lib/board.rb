class Board < Array
  attr_reader :size
  def initialize(size, default_value = nil)
    @size = size
    super(size) { Array.new(size, default_value) } # block sets default value dynamically
  end

  def neighbor_coordinates(row, column)
    previous_row = [row, (row - 1).abs].min
    next_row = [row + 1, size - 1].min
    rows = [previous_row, row, next_row].uniq
    previous_column = [column, (column - 1).abs].min
    next_column = [column + 1, size - 1].min
    columns = [previous_column, column, next_column].uniq
    rows.product(columns) - [[row, column]]
  end

  def neighbors(row, column)
    output = {}
    neighbor_coordinates(row, column).each do |neighbor_row, neighbor_column|
      output[[neighbor_row, neighbor_column]] = self[neighbor_row][neighbor_column]
    end
    output
  end

  def all_coordinates
    (0...size).to_a.product((0...size).to_a)
  end
end
