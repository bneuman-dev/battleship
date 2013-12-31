require_relative 'setup'

class Game
  attr_reader :player1, :player2, :turn

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @turn = @player1
  end
  
  def start_game
    game_on = true
    
    while game_on
      @turn.turn
      if @turn.won?
        game_on = false 

      else
        @turn == @player1 ? @turn = @player2 : @turn = @player1
        puts "Hit ENTER for next turn."
        gets.chomp
      end
    end

    puts "#{@turn.name} wins"
  end
end