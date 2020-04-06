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

    describe '#choose' do
      it 'generates the board with the selected coordinates if not yet generated' do
        expect(test_game).to receive(:generate_hidden_board).with(4,4).and_call_original
        test_game.choose(4,4)
      end

      context 'with a generated board' do
        before { allow(test_game).to receive(:hidden_board).and_return(populated_test_board) }

        it 'does not re-generate the board' do
          expect(test_game).not_to receive(:generate_hidden_board)
          test_game.choose(4,4)
        end

        context 'invalid selections' do
          before { allow(test_game.visible_board).to receive(:choice_valid?).and_return false }

          it 'returns false and makes no changes' do
            pre_test_visible = test_game.visible_board.dup
            expect(test_game.choose(3,3)).to be false
            expect(test_game.visible_board).to eq(pre_test_visible)
          end
        end

        context 'valid selections' do
          it 'puts a ☹️ and makes the entire board visible if choosing a mine' do
            chosen_coordinates = test_mine_map.first
            test_game.choose(*chosen_coordinates)
            touched_cell = test_game.visible_board[chosen_coordinates[0]][chosen_coordinates[1]]
            expect(touched_cell).to eq "☹️"
            expect(test_game.visible_board.flatten).not_to include("■")
          end

          it 'makes the chosen cell visible if not a mine' do
            test_game.choose(4,0)
            expect(test_game.visible_board[4][0]).to eq(test_game.hidden_board[4][0])
          end

          it 'chooses all neighbors if the chosen cell is a 0' do
            allow(test_game.visible_board).to receive(:neighbor_coordinates).and_return([[98,98],[99,99]])
            allow(test_game).to receive(:choose).with(4,4).and_call_original
            expect(test_game).to receive(:choose).with(*[98,98])
            expect(test_game).to receive(:choose).with(*[99,99])
            test_game.choose(4,4)
          end
        end
      end
    end

    describe '#game_over?' do
      it 'returns true if #lost? is truthy' do
        allow(test_game).to receive(:lost?).and_return(true)
        expect(test_game.game_over?).to be true
      end

      it 'returns true if #won? is truthy' do
        allow(test_game).to receive(:won?).and_return(true)
        expect(test_game.game_over?).to be true
      end

      it 'returns false otherwise' do
        allow(test_game).to receive(:lost?).and_return(false)
        allow(test_game).to receive(:won?).and_return(false)
        expect(test_game.game_over?).to be false
      end
    end

    describe '#won?' do
      it 'returns false if lost?' do
        allow(test_game).to receive(:lost?).and_return(true)
        expect(test_game.won?).to be false
      end

      it 'returns true if the the number of non-Integer cells visible are  mines' do
        visible_cells_with_mines_covered_or_flagged = ["*", 2, 1, 0, 0, 3, "⚑", 2, 1, 0, "*", 4, "⚑", 1, 0, 2, "⚑", 2, 1, 0, 1, 1, 1, 0, 0]
        expect(test_game.won?(visible_cells_with_mines_covered_or_flagged)).to be true
      end

      it 'returns false otherwise' do
        expect(test_game.won?).to be false
      end
    end

    describe '#lost?' do
      it 'returns true if a mine has been triggered' do
        expect(test_game.lost?(["☹️"])).to be true
      end

      it 'returns false otherwise' do
        expect(test_game.lost?).to be false
      end
    end
  end
end
