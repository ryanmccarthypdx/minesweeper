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
end
