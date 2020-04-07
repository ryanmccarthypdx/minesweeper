# Minesweeper
Back in college I took a 1-credit half-semester intro computer science course in which the final project was to write minesweeper in C.  I spent hours and hours in the computer lab working on it and getting all of the extra credit because it was such a fun problem.  As a side project I decided to revisit the problem in Ruby and see if I could write an efficient algorithm to solve minesweeper.

## Getting Started
Install ruby
Install bundler `gem install bundler`
Bundle by running `bundle`
To run the specs, run `bundle exec rspec spec -fd`
To play manually, run `ruby minesweeper.rb`
To test the automated solver, run `ruby minesweeper_bot.rb`

## Results
All results are on a 2014 Macbook Air

#### Initial Algorithm
Average time to build:   1.32 milliseconds
Average time per win:    2.87 milliseconds
Percentage of games won: 44.03%
