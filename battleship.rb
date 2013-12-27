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



class Board
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

class Offense_Board
	attr_accessor :enemy_board
	attr_reader :grid, :sunk
	include GridView

	def initialize(enemy_board = nil)
		@grid = Grid.new
		@sunk = []
	end

	def board
		@grid.board
	end

	def view_board
		@grid.view_board
	end

	def shoot(coord)
		result = take_shot(coord)
		mark_result(result)
		result
	end

	def get_coord(coord)
		board[coord[0]][coord[1]]
	end

	def mark_result(result)
		coord = result[:coord]
		board[coord[0]][coord[1]] = result[:result]
		@sunk.push([result[:sunk], coord]) if !!result[:sunk]
	end

	def take_shot(coord)
		@enemy_board.get_shot(coord)
	end

	def already_shot(coord)
		get_coord(coord) != ' '
	end
end

class Player
	attr_reader :board, :offense_board, :name

	def initialize(ships, name)
		@board = Board.new(ships)
		@offense_board = Offense_Board.new
		@name = name
	end

	def set_enemy(enemy)
		@offense_board.enemy_board = enemy
	end

	def shots_count
		@board.number_of_ships - @board.sunk
	end

	def volley(coords)
		raise TooManyShotsException.new if coords.length > shots_count
		raise TooFewShotsException.new if coords.length < shots_count
		raise DuplicateShotsException.new if coords.uniq != coords
		raise AlreadyShotException.new if coords.any? {|coord| @offense_board.already_shot(coord)}
		coords.collect { |coord| shoot(coord)}
	end

	def shoot(coords)
		@offense_board.shoot(coords)
	end
end

class Game
	attr_reader :player1, :player2, :players, :turn
	include CoordTranslator

	def initialize
		

		placer = Ships_Placer.new(ships_conf)
		placer.place
		@player1 = Human_Front_End.new(Player.new(placer.ships, 'Ben'))
		@player1.player.set_enemy(@player2.player.board)
		@player2.player.set_enemy(@player1.player.board)
		@turn = @player1
	end

	def start_game
		game_on = true
		
		while game_on
			
			@turn.turn
			game_on = false if @turn.offense_board.enemy_board.sunk == @turn.offense_board.enemy_board.number_of_ships
			@turn == @player1? @turn = @player2 : @turn = @player1
		end

		puts "#{@turn} wins"
	end

	def check_over(board)
		board.hits.sort == board.coords.sort
	end

	def process_volley_results(results)
		hit_miss = {"H" => "hit", "M" => "miss"}

		results.each do |result|
			puts from_coord(result[:coord]) + ":  " + hit_miss[result[:result]]
			puts "Sunk " + result[:sunk] if result[:sunk]
		end
	end
end

class Computer_Front_End
	attr_reader :player, :offense_board
	include CoordTranslator
	def initialize(player)
		@player = player
		@offense_board = @player.offense_board
	end

	def turn
		make_shots(@player.shot_count)
		@player.volley(shots)
	end

	def make_shots(shot_count)
		shots = []
		shot_count.times do
			shot = make_shot
			while shots.include? shot
				shot = make_shot
			end
			shots.push(shot)
		end

		shots
	end

	def make_shot
		coord = [rand(9), rand(9)]
	end
end

class Human_Front_End
	include CoordTranslator
	attr_reader :player, :offense_board

	def initialize(player)
		@player = player
		@offense_board = @player.offense_board
	end

	def view_board
		@offense_board.grid.view_board
	end

	def turn
		view_board
		puts "#{@player.name}, you have #{@player.shots_count} shots. Shoot"
		
		shoot = true

		while shoot
			shots = gets.chomp

			begin 
				result = @player.volley(process_input(shots))

			rescue TooFewShotsException
				puts "Too few shots, you have #{@player.shots_count} shots. Shoot again."

			rescue TooManyShotsException
				puts "Too many shots, you only have #{@player.shots_count} shots. Shoot again."

			rescue DuplicateShotsException
				puts "You can't shoot the same coordinate twice in the same volley. Shoot again."

			rescue AlreadyShotException
				puts "You already shot one of those coordinates! Shoot again"

			else
				shoot = false
			end
		end

		result
	end


	def process_input(input)
		coords = input.scan(/[A-J|a-j]10|[A-J|a-j][1-9]/)
		coords.collect do |coord|
			to_coord(coord)
		end
	end

end
			

def make_computer_player
	computer_ships = Ships_Maker.new(ships_conf).ships
	computer_player = Player.new(computer_ships, 'Comp')
	computer_front_end = Computer_Front_End.new(computer_player)
end

def ships_conf
 [{name: 'Carrier', length: 5, quantity: 1},
						 {name: 'Battleship', length: 4, quantity: 1},
						 {name: 'Steamboat', length: 3, quantity: 1},
						 {name: 'Destroyer', length: 2, quantity: 2},
						 {name: 'Submarine', length: 1, quantity: 2},
						]
end