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
solve_total_bm = 0
build_total_bm = 0
iterations.times do
  game = nil
  solver = nil
  build_bm = Benchmark.measure {
    game = Game.new(size, mines)
    solver = Solver.new(game)
  }.total
  build_total_bm += build_bm

  wins += 1 && next if game.won? # can only win on first initial move
  solve_bm = Benchmark.measure { solver.solve }.total
  if game.won?
    wins += 1
    solve_total_bm += solve_bm
  end
end
puts "Average time to build:   #{(build_total_bm * 1000/ iterations).round(2)} milliseconds"
puts "Average time per win:    #{(solve_total_bm * 1000/ wins).round(2)} milliseconds"
puts "Percentage of games won: #{((wins * 100).to_f / iterations).round(2)}%"
