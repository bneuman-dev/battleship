require_relative 'lib/setup'

puts "Welcome to Battleship."
puts "Enter your name to start a game."
name = gets.chomp
# TODO Ruby idiomatic GameSetup
# TODO GameSetup, should be accessible lib/game_setup.rb or app/.../game_setup.rb
game = Game_Setup.new(name, 'Computer')
game.start_game
puts "Goodbye."

