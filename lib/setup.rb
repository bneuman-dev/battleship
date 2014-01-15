require_relative 'human_fleet_builder'
require_relative 'auto_fleet_builder'
require_relative 'fleet'
require_relative 'fleet_factory'
require_relative 'coord_translator'
require_relative 'exceptions'
require_relative 'game'
require_relative 'grid'
require_relative 'player'
require_relative 'ship_maker'
require_relative 'shots'

# TODO consider structs
# Struct.new('Ship', 'name', 'carrier', 'quantity')
# TODO, make this a constant
def ships_conf
  # Ruby Idiom, two space soft-tabs, and formatting
  # [
    # {name: 'Carrier', length: 5, quantity: 1},
    # {}
    # ....
  # ]
 [{name: 'Carrier', length: 5, quantity: 1},
             {name: 'Battleship', length: 4, quantity: 1},
             {name: 'Cruiser', length: 3, quantity: 1},
             {name: 'Destroyer', length: 2, quantity: 2},
             {name: 'Submarine', length: 1, quantity: 2},
            ]
end

class Game_Setup
  attr_reader :game

  def initialize(human_name, computer_name)
    @player1 = Player.new(AutoFleetBuilder, HumanShotChooser, human_name)
    @player2 = Player.new(AutoFleetBuilder, ComputerShotChooser, computer_name)
    @player1.set_enemy(@player2)
    @player2.set_enemy(@player1)
    @game = Game.new(@player1, @player2)
  end

  def start_game
    @game.start_game
  end
end
