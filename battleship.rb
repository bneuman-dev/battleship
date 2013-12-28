require_relative 'lib/setup'

puts "Welcome to Battleship."
puts "Enter your name to start a game."
name = gets.chomp
game = Game_Setup.new(name, 'Computer')
game.start_game
puts "Goodbye."

