require 'spec_helper'

describe Game do
  describe '.initialize' do
    it 'starts with nothing visible' do
      test_game = Game.new(5)
      expect(test_game.visible_board).to eq([
        ["■", "■", "■", "■", "■"],
        ["■", "■", "■", "■", "■"],
        ["■", "■", "■", "■", "■"],
        ["■", "■", "■", "■", "■"],
        ["■", "■", "■", "■", "■"]
        ])
    end

    it 'saves arg[0] as size' do
      test_game = Game.new(5)
      expect(test_game.size).to eq 5
    end

    it 'saves arg[1] as mine_count if given arg[1]' do
      test_game = Game.new(5, 7)
      expect(test_game.mine_count).to eq(7)
    end

    it 'saves arg[0] as mine count if not given arg[1]' do
      test_game = Game.new(8)
      expect(test_game.mine_count).to eq(8)
    end
  end

  context 'instance methods' do
    let(:test_game) { Game.new(5) }
    let(:test_mine_map) { [[0,0],[1,1],[2,0],[2,2],[3,1]] }
    let(:populated_test_board) { [
      ["*", 2,  1,  0, 0],
      [ 3, "*", 2,  1, 0],
      ["*", 4, "*", 1, 0],
      [ 2, "*", 2,  1, 0],
      [ 1,  1,  1,  0, 0]
      ] }

    describe '#generate_hidden_board' do
      it 'populates a board with mine_count number of mines' do
        allow(test_game).to receive(:mine_count).and_return 7
        test_game.generate_hidden_board(4,4)
        expect(test_game.hidden_board.flatten.count("*")).to eq 7
      end

      it 'populates the neighbor counts correctly' do
        allow(test_game).to receive(:generate_mine_map)
          .and_return(test_mine_map)
        test_game.generate_hidden_board(4,4)
        expect(test_game.hidden_board).to eq(populated_test_board)
      end

      it 'will not generate a board with a mine in the forbidden position' do
        allow(test_game).to receive(:mine_count).and_return 24 # ie, all but 1 a mine
        test_output = []
        5.times do
          test_game.generate_hidden_board(2,2)
          test_output << test_game.hidden_board[2][2]
        end
        expect(test_output).to eq(Array.new(5, 8)) # everytime, completely surrounded by mines
      end
    end

  end
end
