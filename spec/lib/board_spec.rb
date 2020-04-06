require 'spec_helper'

describe Board do
  let(:test_board) { Board.new(5, "■") }

  describe '#neighbor_coordinates' do
    it 'lists all surrounding cells if in the middle of the board' do
      expect(test_board.neighbor_coordinates(2,2)).to contain_exactly(
        [1,1], [1,2], [1,3],
        [2,1], [2,3],
        [3,1], [3,2], [3,3]
        )
    end

    it 'does not spill over the edge of the board' do
      expect(test_board.neighbor_coordinates(4,4)).to contain_exactly(
        [3,3], [3,4], [4,3]
      )
    end

    it 'does not include itself' do
      expect(test_board.neighbor_coordinates(4,4)).not_to include([4,4])
    end
  end

  describe '#all_coordinates' do
    it 'returns a list of all possible cooridinates' do
      expect(test_board.all_coordinates.uniq.count).to eq(test_board.flatten.count)
    end
  end

  describe '#neighbors' do
    before do
      test_board[0] = ["a", "b", "c"]
      test_board[1] = ["d", "SHOULD NOT BE SHOWN", "e"]
      test_board[2] = ["f", "g", "h"]
    end

    let(:test_input_coordinates) {[1,1]}
    let(:test_neighbors_output) { test_board.neighbors(*test_input_coordinates) }

    it 'collects the neighboring values, keyed to their coordinates' do
      expect(test_neighbors_output.keys).to eq(test_board.neighbor_coordinates(*test_input_coordinates))
      expect(test_neighbors_output.values).to eq(("a".."h").to_a)
    end
  end

  describe '#choice_valid?' do
    it 'returns false if given an out-of-range selection' do
      expect(test_board.choice_valid?(test_board.size + 1, test_board.size + 1)).to be false
    end

    it 'returns false and if given an already-visible selection' do
      test_board[3][3] = 1
      expect(test_board.choice_valid?(3,3)).to be false
    end

    it 'returns true if given a not-yet-visible selection' do
      expect(test_board.choice_valid?(3,3)).to be true
    end
  end
end
