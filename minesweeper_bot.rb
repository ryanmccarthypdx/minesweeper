#!/usr/local/bin/ruby

# This is a script to have the Solver play minesweeper.

require 'bundler'
require './lib/game.rb'
require './lib/solver.rb'
require 'benchmark'

Bundler.require(:default)

size = 0
mines = Float::INFINITY

until size > 2 do
  puts "How big should the board be? (must be larger than 2)"
  size = gets.chomp.to_i
  puts "Must be between 2-100" unless size > 2
end

maximum_mines = size**2 - 1
until mines < maximum_mines
  puts "How many mines? (Hitting Enter will result in #{size} mines)"
  mines = gets.chomp.to_i
end

puts "How many iterations do you want it to play? (Hitting Enter will result in 100,000 iterations)"
iterations = gets.chomp.to_i
iterations = 100000 if iterations == 0

wins = 0
benchmark = Benchmark.measure {
  iterations.times do
    game = Game.new(size, mines)
    solver = Solver.new(game)
    wins += 1 if game.won? # can only win on first initial move
    wins += 1 if solver.solve
  end
}
puts "Total time to run #{iterations} games: #{benchmark.total}"
puts "Average time per game: #{benchmark.total / iterations}"
puts "Wins: #{wins} (#{wins * 100/ iterations}%)"
