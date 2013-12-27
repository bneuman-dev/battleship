require_relative 'ship'
require_relative 'coord'
require_relative 'board'

class TooManyShotsException < Exception
end

class TooFewShotsException < Exception
end

class AlreadyShotException < Exception
end

class InvalidShipException < Exception
end

class BadShipCoordsException < Exception
end

class DuplicateShotsException < Exception
end

def ships_conf
 [{name: 'Carrier', length: 5, quantity: 1},
						 {name: 'Battleship', length: 4, quantity: 1},
						 {name: 'Steamboat', length: 3, quantity: 1},
						 {name: 'Destroyer', length: 2, quantity: 2},
						 {name: 'Submarine', length: 1, quantity: 2},
						]
end

class Ship
	attr_reader :name, :coords, :length

	def initialize(config_hash)
		@name = config_hash[:name]
		@length = config_hash[:length]
		@coords = config_hash[:coords]
	end
end

class Ships
	attr_reader :ships

	def initialize(ships = [])
		@ships = []
		ships.each {|ship| add_ship(ship)}
	end

	def coords
		@ships.collect {|ship| ship.coords}.flatten(1)
	end

	def find_ship(coords)
		@ships.find { |ship| ship.coords.include? coords }
	end

	def number_of_ships
		@ships.length
	end

	def create_new_ship(ship_cfg, index=nil)
		add_ship(Ship_Adder.new(ship_cfg, self.coords).ship, index)
	end

	def add_ship(ship, index=nil)
		unless index
			@ships.push(ship) 
		else
			if index == @ships.length
				@ships.push(ship) 
			else
				@ships.insert(index, ship)
			end
		end
	end

	def delete_ship(ship)
		@ships.delete(ship)
	end
end



class Fleet
	attr_reader :hits, :sunk

	def initialize(ships)
		@ships = ships
		@hits = []
		@sunk = 0
	end

	def coords
		@ships.coords
	end

	def find_ship(coord)
		@ships.find_ship(coord)
	end

	def number_of_ships
		@ships.number_of_ships
	end

	def get_shot(coord)
		if hit?(coord)
			@hits.push(coord)
			sunk = sunk?(coord)
			{result: 'H', coord: coord, sunk: sunk}
			
		else
			{result: 'M', coord: coord}
		end
	end

	def hit?(coord)
		coords.include? coord
	end

	def sunk?(coord)
		ship = find_ship(coord)
		if ship.coords.all? {|coord| @hits.include? coord}
			@sunk += 1
			ship.name
		else
			false
		end
	end

end

class Attack_Grid
	attr_reader :sunk
	include GridView

	def initialize
		make_grid
		@sunk = []
	end

	def get_coord(coord)
		@grid[coord[0]][coord[1]]
	end

	def mark_result(result)
		coord = result[:coord]
		@grid[coord[0]][coord[1]] = result[:result]
		@sunk.push([result[:sunk], coord]) if !!result[:sunk]
	end

	def already_shot(coord)
		get_coord(coord) != ' '
	end
end

class Combatant
	attr_reader :fleet, :attack_grid, :name

	def initialize(ships)
		@fleet = Fleet.new(ships)
		@attack_grid = Attack_Grid.new
		@name = name
	end

	def set_enemy(enemy)
		@enemy = enemy.fleet
	end

	def shots_count
		@fleet.number_of_ships - @fleet.sunk
	end

	def shots_left
		@attack_grid.shots_left
	end

	def volley(coords)
		results = coords.collect { |coord| shoot(coord)}
		results.each { |result| mark_result(result) }
		results
	end

	def shoot(coord)
		@enemy.get_shot(coord)
	end

	def mark_result(result)
		@attack_grid.mark_result(result)
	end

	def won?
		@attack_grid.sunk.length == @fleet.number_of_ships
	end

	def already_shot(volley)
		volley.select { |shot| @attack_grid.already_shot(shot)}
	end
end

class Player
	include VolleyResultsViewer

	attr_reader :name, :combatant
	def initialize(combatant, shot, name)
		@combatant = combatant
		@shot = shot
		@name = name
	end

	def turn
		shots = @shot.new(@combatant, @name).shots
		results = @combatant.volley(shots)
		view_volley_results(results, self)
	end

	def won?
		@combatant.won?
	end

	def set_enemy(enemy)
		enemy.make_enemy(@combatant)
	end

	def make_enemy(enemy_comb)
		@combatant.set_enemy(enemy_comb)
	end
end

class Human_Shot
	attr_reader :shots
	include CoordTranslator

	def initialize(combatant, name)
		@shots_count = combatant.shots_count
		@combatant = combatant
		@name = name
		@combatant.attack_grid.view_grid
		puts "#{@name}, you have #{@shots_count} shots. Shoot"
		@shots = make_shots
	end

	def make_shots
		shots = gets.chomp

		shots = process_input(shots)

		if shots.length < @shots_count && shots.length < @combatant.shots_left
			puts "Too few shots, you have #{@shots_count} shots. Shoot again."
	

		elsif shots.length > @shots_count
			puts "Too many shots, you only have #{@shots_count} shots. Shoot again."

		elsif shots.uniq != shots
			puts "You can't shoot the same coordinate twice in the same volley. Shoot again."

		elsif @combatant.already_shot(shots) != []
			puts "You already shot #{@combatant.already_shot(shots)}"

		else
			return shots
		end

		make_shots
	end

	def process_input(input)
		coords = input.scan(/[A-J|a-j]10|[A-J|a-j][1-9]/)
		coords.collect do |coord|
			to_coord(coord)
		end
	end
end

class Computer_Shot
	attr_reader :shots
	def initialize(combatant, name)
		@shots_count = combatant.shots_count
		@combatant = combatant
		@name = name
		@shots = make_shots
	end

	def make_shots
		shots = []

		@shots_count.times do
			shot = make_shot
			while shots.include? shot
				shot = make_shot
			end
			shots.push(shot)
		end

		if @combatant.already_shot(shots) != []
			make_shots

		else
			shots
		end
	end

	def make_shot
		[rand(9), rand(9)]
	end
end

class Game
	attr_reader :player1, :player2, :turn
	include CoordTranslator

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
			end
		end

		puts "#{@turn.name} wins"
	end
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
		comb = Combatant.new(make_computer_ships)
		Player.new(comb, Human_Shot, name)
	end

	def make_computer_player(name)
		comb = Combatant.new(make_computer_ships)
		Player.new(comb, Computer_Shot, name)
	end

	def make_human_ships
		placer = Ships_Placer.new(ships_conf)
		placer.place
		placer.ships
	end

	def make_computer_ships
		Ships_Maker.new(ships_conf).ships
	end

	def start_game
		@game.start_game
	end

end


puts "Welcome to Battleship."
puts "Type your name to start playing."
name = gets.chomp
game_setup = Game_Setup.new(name, 'Benito M.')

puts "Goodbye."


=begin
	FROM volley()
	raise TooManyShotsException.new if coords.length > shots_count
		raise TooFewShotsException.new if coords.length < shots_count
		raise DuplicateShotsException.new if coords.uniq != coords
		raise AlreadyShotException.new if coords.any? {|coord| @attack_grid.already_shot(coord)}
=end

=begin
			begin 
				results = @combatant.volley(process_input(shots))

			rescue TooFewShotsException
				puts "Too few shots, you have #{@combatant.shots_count} shots. Shoot again."

			rescue TooManyShotsException
				puts "Too many shots, you only have #{@combatant.shots_count} shots. Shoot again."

			rescue DuplicateShotsException
				puts "You can't shoot the same coordinate twice in the same volley. Shoot again."

			rescue AlreadyShotException
				puts "You already shot one of those coordinates! Shoot again"

			else
				shoot = false
				view_volley_results(results, self)
			end
		end
	end
=end
