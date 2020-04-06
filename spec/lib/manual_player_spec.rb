require 'spec_helper'

describe ManualPlayer do
  before do
    allow($stdout).to receive(:write)
  end

  let(:test_player) { ManualPlayer.new(test_game) }
  describe '.initialize' do
    let(:test_game) { Game.new(12) }

    it 'generates the header_row as a properly-spaced string' do
      expect(test_player.header_row).to eq "  | 0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11"
    end

    it 'generates the header_column as an ordered array of properly-spaced strings' do
      expect(test_player.header_column).to eq [" 0", " 1", " 2", " 3", " 4", " 5", " 6", " 7", " 8", " 9", "10", "11"]
    end
  end

  context 'instance methods' do
    let(:test_game) { Game.new(4) }

    describe '#display_visible_board' do
      let(:test_visible) { [[1,2,3,4], [5,6,7,8], [9,0,1,2], [3,4,5,6]] }

      it 'outputs the visible board with header row and column' do
        expect{ test_player.display_visible_board(test_visible) }.to output(a_string_including(test_player.header_row)).to_stdout
        expect{ test_player.display_visible_board(test_visible) }.to output(a_string_including(" 0| 1  2  3  4")).to_stdout
        expect{ test_player.display_visible_board(test_visible) }.to output(a_string_including(" 1| 5  6  7  8")).to_stdout
        expect{ test_player.display_visible_board(test_visible) }.to output(a_string_including(" 2| 9  0  1  2")).to_stdout
        expect{ test_player.display_visible_board(test_visible) }.to output(a_string_including(" 3| 3  4  5  6")).to_stdout
      end
    end

    describe '#manual_play' do
      context 'when the game is over' do
        it 'plays turns until the game is over' do
          allow(test_game).to receive(:game_over?).and_return(false, false, true)
          expect(test_player).to receive(:play_a_turn).thrice
          test_player.manual_play
        end

        it 'stops playing and displays the final results once the game is over' do
          allow(test_game).to receive(:game_over?).and_return(true)
          expect(test_player).to receive(:play_a_turn).once
          expect(test_player).to receive(:display_final_results)
          test_player.manual_play
        end
      end
    end

    describe '#play_a_turn' do
      before { allow(test_player).to receive(:gets).and_return('1\n', '2\n') }

      it 'clears the display before displaying the board' do
        # generally #ordered is not recommended but important here
        expect(test_player).to receive(:clear_screen).ordered
        expect(test_player).to receive(:display_visible_board).ordered
        test_player.play_a_turn
      end

      it 'takes user input for row and column and passes that on to Game#choose' do
        expect(test_game).to receive(:choose).with(1,2)
        test_player.play_a_turn
      end
    end

    describe '#display_final_results' do
      it 'clears the screen before displaying the final visible' do
        # generally #ordered is not recommended but important here
        expect(test_player).to receive(:clear_screen).ordered
        expect(test_player).to receive(:display_visible_board).ordered
        test_player.display_final_results
      end

      it 'announces if the player won' do
        allow(test_game).to receive(:won?).and_return(true)
        expect{ test_player.display_final_results }.to output(a_string_including("YOU WON!")).to_stdout
      end

      it 'announces if the player lost' do
        allow(test_game).to receive(:won?).and_return(false)
        expect{ test_player.display_final_results }.to output(a_string_including("YOU LOST!")).to_stdout
      end
    end
  end
end
