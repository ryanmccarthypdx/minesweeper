#!/usr/local/bin/ruby

# This is a script to run a local terminal version of minesweeper manually.

require 'bundler'
require './lib/game.rb'
require './lib/manual_player.rb'

Bundler.require(:default)

puts "How big should the board be? (must be between 2-100)"
size = gets.chomp.to_i
unless (2..100).include?(size)
  puts "Must be between 2-100"
  return
end

puts "How many mines? (or just hit enter for #{size} mines)"
mines = gets.chomp.to_i

player = ManualPlayer.new(Game.new(size, mines))
player.manual_play
