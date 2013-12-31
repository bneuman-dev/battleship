require_relative 'game'
require_relative 'player'
require_relative 'fleet_factory'
require_relative 'shots'

def ships_conf
 [{name: 'Carrier', length: 5, quantity: 1},
						 {name: 'Battleship', length: 4, quantity: 1},
						 {name: 'Cruiser', length: 3, quantity: 1},
						 {name: 'Destroyer', length: 2, quantity: 2},
						 {name: 'Submarine', length: 1, quantity: 2},
						]
end

class Game_Setup
	attr_reader :player1, :player2, :game

	def initialize(human_name, computer_name)
		@player1 = make_human_player(human_name)
		@player2 = make_computer_player(computer_name)
		@player1.set_enemy(@player2)
		@player2.set_enemy(@player1)
		@game = Game.new(@player1, @player2)
	end

	def make_human_player(name)
		comb = Combatant.new(make_human_fleet)
		Player.new(comb, Human_Shot, name)
	end

	def make_computer_player(name)
		comb = Combatant.new(make_computer_fleet)
		Player.new(comb, Computer_Shot, name)
	end

	def make_human_fleet
		Fleet_Factory.new(Human_Fleet_Builder, ships_conf).fleet
	end

	def make_computer_fleet
		Fleet_Factory.new(Auto_Fleet_Builder, ships_conf).fleet
	end

	def start_game
		@game.start_game
	end
end