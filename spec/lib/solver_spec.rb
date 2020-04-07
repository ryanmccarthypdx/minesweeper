require 'spec_helper'

describe Solver do
  let(:test_game) { Game.new(5) }

  describe '.initialize' do
    it 'makes an initial choice near the center of board' do
      expect(test_game).to receive(:choose).with(2,2)
      Solver.new(test_game)
    end
  end

  context 'instance methods' do
    let(:test_solver) { Solver.new(test_game) }

    describe '#solve' do
      before do
        allow(test_solver).to receive(:solve_until_won).and_return false
      end

      it 'evaluates the choices based on the visible board' do
        expect(test_solver).to receive(:find_best_choices_and_flag_mines).and_call_original
        test_solver.solve
      end

      it 'checks to see if it has won after making a choice' do
        expect(test_solver).to receive(:solve_until_won)
        test_solver.solve
      end

      it 'returns the result of solve_until_won' do
        expect(test_solver.solve).to eq false
      end

      context 'when find_best_choice is able to evaluate the board' do
        before do
          allow(test_solver).to receive(:find_best_choices_and_flag_mines)
            .and_return [[0,0],[0,1]]
        end

        it 'chooses all of the results from find_best_choices_and_flag_mines' do
          expect(test_game).to receive(:choose).with(0,0).once
          expect(test_game).to receive(:choose).with(0,1).once
          test_solver.solve
        end

        it 'chooses all of the results to find_best_choices_and_flag_mines before checking if it won' do
          expect(test_game).to receive(:choose).twice.ordered
          expect(test_solver).to receive(:solve_until_won).ordered
          test_solver.solve
        end
      end

      context 'when find_best_choice has no choice' do
        before do
          allow(test_solver).to receive(:find_best_choices_and_flag_mines)
            .and_return []
          allow(test_solver).to receive(:wild_guess).and_return([99,99])
        end
        it 'makes a wild guess' do
          expect(test_game).to receive(:choose).with(99,99)
          test_solver.solve
        end
      end
    end

    describe '#solve_until_won' do
      context 'if the game is over' do
        before { allow(test_game).to receive(:game_over?).and_return(true) }

        it 'returns the result of Game#won?' do
          allow(test_game).to receive(:won?).and_return("_")
          expect(test_solver.solve_until_won).to eq("_")
        end
      end

      it 'takes another turn if game is NOT over' do # default behavior
        expect(test_solver).to receive(:solve)
        test_solver.solve_until_won
      end
    end

    describe '#find_best_choices_and_flag_mines' do
      let(:test_visible_board) { Board.new(5) }
      let(:test_visible_state) { [
          ["⚑", 1,  2 , "■", "■"],
          [ 1 , 2,  3 , "■", "■"],
          [ 0 , 1, "■", "■", "■"],
          [ 0 , 1,  2 , "■", "■"],
          [ 0 , 0,  1 , "■", "■"]
        ] }
      before do
        test_visible_state.each_with_index { |r, i| test_visible_board[i] = r }
        allow(test_visible_board).to receive(:neighbors).and_call_original
      end

      it "skips evaluating cells that are known 0s" do
        expect(test_visible_board).not_to receive(:neighbors).with(2,0)
        test_solver.find_best_choices_and_flag_mines(test_visible_board)
      end

      it 'skips evaluating cells that are flagged' do
        expect(test_visible_board).not_to receive(:neighbors).with(0,0)
        test_solver.find_best_choices_and_flag_mines(test_visible_board)
      end

      it 'flags all known mines' do
        test_solver.find_best_choices_and_flag_mines(test_visible_board)
        expect(test_visible_board[2][2]).to eq("⚑")
      end

      context 'when the current answer is ambiguous' do # this is the default situation
        it 'gives the best option available' do
          expect(test_solver.find_best_choices_and_flag_mines(test_visible_board)).to eq [[2,3]]
        end
      end

      context 'when there are safe choices' do
        let(:test_visible_state) { [
            ["■", 1,  1 ,  2 , "■"],
            ["■", 1, "■",  3 ,  2 ],
            ["■", 2,  2 ,  3 , "■"],
            ["■", 1, "■",  3 ,  2 ],
            ["■", 1,  1 ,  2 , "■"]
          ] }

        it 'returns an array of all safe choices, but only once per' do
          expect(test_solver.find_best_choices_and_flag_mines(test_visible_board))
            .to contain_exactly(
              [0,0], [1,0], [2,0], [3,0], [4,0]
            )
        end
      end

      context 'when a 0-risk choice comes along later' do
        let(:test_visible_state) { [
            ["■", 1,  0 ,  1 , "■"],
            ["■", 2,  0 ,  2 ,  2 ],
            ["■", 1,  0 ,  2 , "■"],
            ["⚑", 1,  0 ,  2 ,  2 ],
            ["■", 1,  0 ,  1 , "■"]
          ] }

        it 'only returns the 0-risk choice(s)' do
          expect(test_solver.find_best_choices_and_flag_mines(test_visible_board))
            .to contain_exactly([1, 0], [2, 0], [4, 0])
        end
      end

      context 'when all possible choices are blind guesses' do
        let(:test_visible_state) { [
            ["■", "■", "■", "■", "■"],
            ["■", "⚑", "⚑", "⚑", "■"],
            ["■", "⚑",  8 , "⚑", "■"],
            ["■", "⚑", "⚑", "⚑", "■"],
            ["■", "■", "■", "■", "■"],
          ] }

        it 'returns an empty array' do
          expect(test_solver.find_best_choices_and_flag_mines(test_visible_board)).to be_empty
        end
      end
    end

    describe '#wild_guess' do
      let(:test_visible_state) { [
          ["■","⚑", 2 , 0 , 0 ],
          ["⚑","⚑", 2 , 0 , 0 ],
          [ 2 , 2 , 1 , 0 , 0 ],
          [ 0 , 0 , 0 , 1 , 1 ],
          [ 0 , 0 , 0 , 1 ,"⚑"]
        ] }
      it 'always returns the coordinates of an unchosen cell' do
        expect(test_solver.wild_guess(test_visible_state)).to eq([0,0])
      end

      it 'raises an error if the visible board has no unknowns' do
        expect{test_solver.wild_guess([["⚑","⚑","⚑"],[1,2,1],[0,0,0]])}.to raise_error(StandardError, "Infinite loop initiated!")
      end
    end
  end
end
